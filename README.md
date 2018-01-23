# Example Concierge managed Apache httpd as a proxy 

## Introduction 
With this repository we intend to demonstrate a few features of what we can achieve by using the Concierge Paradigm and the concierge-app-playbook.

In the deployment we have an Apache Webserver, configured as a forward proxy. It proxies to a Squid Proxy, also configured in forward proxy mode and set up to allow requests only to Google APIs.

This was used as an example so as to demonstrate using active discovery to configure:
* Apache with new and updated upstream servers
* Squid with dynamic ACLs for downstream clients 

We also demonstrate how to take advantage of inside-container orchestration for:
* understand our local environment and preconfigure our application 
* understand our wider system environment and run jobs based on conditions 
* monitor the health of our applications and report their state for other systems to consume 

Lastly, we show how the playbook provides a consistent and simple mechanism to generate container images, scheduling and orchestration code.
