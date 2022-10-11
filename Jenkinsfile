pipeline {
  environment {
    ID_DOCKER = "${ID_DOCKER_PARAMS}"
    IMAGE_NAME = "${IMAGE_NAME_PARAMS}"
    IMAGE_TAG = "latest"
//  PORT_EXPOSED = "80" à paraméter dans le job
    // STAGING = "${ID_DOCKER}-staging"
    // PRODUCTION = "${ID_DOCKER}-production"
  }
  agent none
  stages {
    stage('Build image') {
      agent any
      steps {
        script {
          sh 'docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .'
        }
      }
    }
    stage('Scan Trivy') {
      agent any
      steps {
     // Install trivy
        sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.18.3'
        sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl > html.tpl'

        // Scan all vuln levels
        // sh 'mkdir -p reports'
        // sh 'trivy filesystem --ignore-unfixed --vuln-type os,library --format template --template "@html.tpl" -o reports/nodjs-scan.html ./nodejs'
        // sh "trivy filesystem --ignore-unfixed --vuln-type os,library --format template --template '@html.tpl' -o reports/nodjs-scan.html ./nodejs"

        // sh "trivy image ${IMAGE_NAME}"
        // publishHTML target : [
        //     allowMissing: true,
        //     alwaysLinkToLastBuild: true,
        //     keepAll: true,
        //     reportDir: 'reports',
        //     reportFiles: 'nodjs-scan.html',
        //     reportName: 'Trivy Scan',
        //     reportTitles: 'Trivy Scan'
        // ]

        // Scan again and fail on CRITICAL vulns
        sh 'trivy image --no-progress --exit-code 0 --severity CRITICAL ${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}'
      }
    }
    stage('Run container based on builded image') {
      agent any
      steps {
        script {
          sh '''
            echo "Clean Environment"
            docker rm -f $IMAGE_NAME || echo "container does not exist"
            docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:5000 -e PORT=5000 ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
            sleep 5
             '''
        }
      }
    }
    stage('Test image') {
      agent any
      steps {
        script {
          sh '''
            curl -I http://172.17.0.1:${PORT_EXPOSED} | grep -q "200"
             '''
        }
      }
    }
    stage('Clean Container') {
      agent any
      steps {
        script {
          sh '''
            docker stop $IMAGE_NAME
            docker rm $IMAGE_NAME
             '''
        }
      }
    }
    stage ('Login and Push Image on docker hub') {
      agent any
      environment {
        DOCKERHUB_PASSWORD  = credentials('dockerhub')
      }            
      steps {
        script {
          sh '''
            echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
            docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
             '''
        }
      }
    }    
    stage('Push image in staging and deploy it') {
      when {
        expression { GIT_BRANCH == 'origin/master' }
      }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
        script {
          sh '''
            heroku container:login
            heroku create $STAGING || echo "project already exist"
            heroku container:push -a $STAGING web
            heroku container:release -a $STAGING web
            '''
        }
      }
    }
    stage('Push image in production and deploy it') {
      when {
        expression { GIT_BRANCH == 'origin/production' }
      }
      agent any
      environment {
        HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
        script {
          sh '''
            heroku container:login
            heroku create $PRODUCTION || echo "project already exist"
            heroku container:push -a $PRODUCTION web
            heroku container:release -a $PRODUCTION web
            '''
        }
      }
    }
  }
  post {
    success {
      slackSend (
        botUser: true,
        color: '#00FF00', 
        message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})", 
        tokenCredentialId: 'slack-token', 
        channel: 'jenkins'
      )
    }
    failure {
      slackSend (
        botUser: true,
        color: '#FF0000', 
        message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
        tokenCredentialId: 'slack-token', 
        channel: 'jenkins'
      )
    }   
  }
}