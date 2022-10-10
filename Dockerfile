FROM python:3.6-alpine
WORKDIR /opt
RUN pip install flask==1.1.2
EXPOSE 8080
ENV ODOO_URL ""
ENV PGADMIN_URL ""
COPY app.py ic-webapp/
COPY templates/ ic-webapp/templates/
COPY static/ ic-webapp/static/
COPY images/ ic-webapp/images/
ENTRYPOINT ["python", "ic-webapp/app.py"]
