FROM registry.cn-hangzhou.aliyuncs.com/baibaicloud/baibai-frp:base

MAINTAINER baibai

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN mkdir /logs
COPY frps /frps
COPY frps.ini /frps.ini
RUN chmod 777 /frps

ENTRYPOINT ["sh","-c","/frps -c /frps.ini"]