FROM --platform=linux/amd64 nginx:latest

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]