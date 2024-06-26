FROM httpd

#updating the system
RUN apt update -y 

#variables
ARG port=80

#Installing useful packages
Run apt install -y unzip

#Container working directory
WORKDIR /usr/local/apache2/htdocs/

#Preparing the folder++
RUN rm -rf * 

#collecting the developer code
ADD  . .

#expose the container
EXPOSE ${port}





