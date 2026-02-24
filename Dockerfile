FROM nginx:latest

# ลบ default html
RUN rm -rf /usr/share/nginx/html/*

# copy web content
COPY index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
