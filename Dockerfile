FROM nginx:bookworm

WORKDIR /home
RUN apt update -y \
	&& apt upgrade -y \
 	&& apt install -y nginx supervisor vim screen wget curl git sudo
	
RUN git clone https://github.com/puge2/huggingface-nn.git
WORKDIR /home/huggingface-nginx

RUN useradd -m -u 1000 www

RUN touch /var/run/nginx.pid && \
  chown -R www:www /var/run/nginx.pid && \
  chown -R www:www /var/cache/nginx
  
USER www

ENV HOME=/home/www \
	PATH=/home/www/.local/bin:$PATH
	
RUN cp /home/huggingface-nginx/configure.sh /home/www/configure.sh \
	&& cp /home/huggingface-nginx/script/supervisord.conf /etc/supervisord.conf

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --chown=www ./index.html /var/www/html/index.html
COPY --chown=www ./web.conf /etc/nginx/sites-available/web.conf

RUN /bin/bash -c 'chmod 755 /home/huggingface-nginx && mv /home/huggingface-nginx/script/bin/* /bin/ '
RUN apt update -y \
	&& mkdir -p /run/screen \
	&& chmod -R 777 /run/screen \
	&& chmod +x /home/www/configure.sh \
	&& chmod +x /bin/frpc \
	&& chmod +x /bin/ttyd

EXPOSE 8080
ENV LANG C.UTF-8

CMD /home/www/configure.sh