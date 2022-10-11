pipeline {
  environment {
    ID_DOCKER = "fredlab"
    IMAGE_NAME = "ic-webapp"
    PORT_EXPOSED = "80"
    DOCKERHUB_PASSWORD  = credentials('dockerhub')
    ODOO = "${sh(script:'awk \'/ODOO/ {sub(/^.**URL/,\"\");print $2}\' releases.txt', returnStdout: true).trim()}"
    PGADMIN = "${sh(script:'awk \'/PGADMIN/ {sub(/^.**URL/,\"\");print $2}\' releases.txt', returnStdout: true).trim()}"
    VER = "${sh(script:'awk \'/version:/ {sub(/^.**version:/,\"\");print $1}\' releases.txt', returnStdout: true).trim()}"
  }
  agent none
  stages {
    stage('Build ic-webapp image') {
      agent any
      steps {
        script {
          sh '''
            echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
            docker build --build-arg odoo=${ODOO} --build-arg pgadmin=${PGADMIN} -t ${ID_DOCKER}/${IMAGE_NAME}:${VER} .             
            '''
        }
      }
    }
    stage('Run container based on builded image') {
      agent any
      steps {
        script {
          sh '''
            echo "Clean Environment"
            docker rm -f $IMAGE_NAME || echo "container does not exist"
            docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:8080 ${ID_DOCKER}/$IMAGE_NAME:$VER
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
            curl -I http://127.0.0.1:${PORT_EXPOSED} | grep -q "les titres de la page"
             '''
        }
      }
    }
//     stage('Clean Container') {
//       agent any
//       steps {
//         script {
//           sh '''
//             docker stop $IMAGE_NAME
//             docker rm $IMAGE_NAME
//              '''
//         }
//       }
//     }
//     stage ('Login and Push Image on docker hub') {
//       agent any
//       environment {
//         DOCKERHUB_PASSWORD  = credentials('dockerhub')
//       }            
//       steps {
//         script {
//           sh '''
//             echo $DOCKERHUB_PASSWORD_PSW | docker login -u $ID_DOCKER --password-stdin
//             docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
//              '''
//         }
//       }
//     }    
//     stage('Push image in staging and deploy it') {
//       when {
//         expression { GIT_BRANCH == 'origin/master' }
//       }
//       agent any
//       environment {
//         HEROKU_API_KEY = credentials('heroku_api_key')
//       }  
//       steps {
//         script {
//           sh '''
//             heroku container:login
//             heroku create $STAGING || echo "project already exist"
//             heroku container:push -a $STAGING web
//             heroku container:release -a $STAGING web
//             '''
//         }
//       }
//     }
//     stage('Push image in production and deploy it') {
//       when {
//         expression { GIT_BRANCH == 'origin/production' }
//       }
//       agent any
//       environment {
//         HEROKU_API_KEY = credentials('heroku_api_key')
//       }  
//       steps {
//         script {
//           sh '''
//             heroku container:login
//             heroku create $PRODUCTION || echo "project already exist"
//             heroku container:push -a $PRODUCTION web
//             heroku container:release -a $PRODUCTION web
//             '''
//         }
//       }
//     }
//   }
//   post {
//     success {
//       slackSend (
//         botUser: true,
//         color: '#00FF00', 
//         message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})", 
//         tokenCredentialId: 'slack-token', 
//         channel: 'jenkins'
//       )
//     }
//     failure {
//       slackSend (
//         botUser: true,
//         color: '#FF0000', 
//         message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})",
//         tokenCredentialId: 'slack-token', 
//         channel: 'jenkins'
//       )
//     }   
  }
}