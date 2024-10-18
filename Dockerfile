# Use the official Nginx image to serve the static files
FROM nginx:alpine

# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy the HTML, CSS, and JavaScript files to the Nginx directory
COPY index.html .
COPY app.js .
COPY style.css .

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
