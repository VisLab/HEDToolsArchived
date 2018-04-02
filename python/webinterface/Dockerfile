FROM tiangolo/uwsgi-nginx-flask:python3.6
COPY ./app /app
COPY ./requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r /app/requirements.txt
RUN mkdir /var/log/hedtools
ENV STATIC_PATH /app/webinterface/static
ENV STATIC_URL /hed/static
