FROM tiangolo/uwsgi-nginx-flask:python3.6
COPY ./app /app
COPY ./requirements.txt /app/
RUN pip install -r /app/requirements.txt
ENV STATIC_PATH /app/webinterface/static
