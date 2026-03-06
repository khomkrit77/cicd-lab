FROM nginx:alpine

# สั่งอัปเดต package ในเครื่องให้เป็นเวอร์ชันใหม่ล่าสุดเพื่อปิดช่องโหว่
RUN apk update && apk upgrade
# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# เปลี่ยนจากระบุชื่อไฟล์ เป็นการ copy ทุกอย่างในโฟลเดอร์ปัจจุบันเข้าไป
COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
