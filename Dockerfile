FROM nginx:latest

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# เปลี่ยนจากระบุชื่อไฟล์ เป็นการ copy ทุกอย่างในโฟลเดอร์ปัจจุบันเข้าไป
COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
