FROM nginx:latest
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY certs/nginx-selfsigned.crt /etc/nginx/certs/nginx-selfsigned.crt
COPY certs/nginx-selfsigned.key /etc/nginx/certs/nginx-selfsigned.key
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
