# Use the official Nginx image as the base
FROM nginx:alpine

# Remove the default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your static files (app.js, index.html, and any other assets) to the Nginx HTML directory
COPY . /usr/share/nginx/html

# Expose port 80 (the default Nginx port)
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]