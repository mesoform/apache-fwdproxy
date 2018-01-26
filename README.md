# Example Concierge managed Apache httpd as a proxy

## Introduction
With this repository we intend to demonstrate a few features of what we can automate by using the 
[Concierge Paradigm](http://www.mesoform.com/blog-listing/info/the-concierge-paradigm) and the 
[concierge-app-playbook](https://github.com/mesoform/concierge-app-playbook).
In the deployment we have an [Apache Webserver](http://httpd.apache.org), configured as a 
[forward proxy](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html#forwardreverse). It proxies requests from our local
 [Google Cloud SDK](https://cloud.google.com/sdk/) commands to a [Squid Proxy](http://squid-cache.org/), also configured in 
 forward proxy mode and set up to allow requests only to [Google APIs](https://cloud.google.com/apis/).
This was used as an example so as to demonstrate using [active discovery](https://containersummit.io/articles/active-vs-passive-discovery)
 to configure:
* Apache with new and updated upstream servers
* Squid with dynamic ACLs for downstream clients
We also demonstrate how to take advantage of [inside-container orchestration](http://autopilotpattern.io) for:
* understand our local environment and preconfigure our application
* understand our wider system environment and run jobs based on conditions
* monitor the health of our applications and report their state for other systems to consume
Lastly, we show how the playbook provides a consistent and simple mechanism to generate container images, scheduling and 
orchestration code.

## How we got set up 
Firstly I created a Github repository (the one you're looking at) for our new applications (click over to the Squid one to read
 about that one) and a local directory of the same name. 

Afterwards, I cloned the [concierge-app-playbook](https://github.com/mesoform/concierge-app-playbook) repository to a local 
directory, just like any other repository. Once copied locally, I got set up by running `./setup.sh --initialise-git` like 
[mentioned in the documentation](https://github.com/mesoform/concierge-app-playbook#setting-up) and answered the questions, when
 prompted. Have a look at the [defaults file](https://github.com/mesoform/apache-fwdproxy/blob/master/defaults/main.yml) to see 
 how I answered them.

Now we have our local development environment set up along with some primitives about our project.

Next we need to give the playbook instructions how to install our application. We didn't want to restrict people to having to 
learn the intrinsic details of Docker, so this is done by providing a normal script or set of scripts to the playbook. In this 
example we demonstrate this by [compiling Apache in one script](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/compile.sh)
 and performing [other activities in another](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/install.sh). We 
 also drop any static configuration files into the 
 [files/etc directory](https://github.com/mesoform/apache-fwdproxy/tree/master/files/etc) (ignore containerpilot.json5 for now) 
 and any Jinja2 templates into the [templates/app directory](https://github.com/mesoform/apache-fwdproxy/tree/master/templates/app).

In this paradigm, orchestration is the responsibility of the applications owners (who know best how it should operate) and 
executed by [Containerpilot](https://github.com/joyent/containerpilot) running inside the container. Orchestration can be as 
simple as passing commands to start and reload the application but also more powerful by supplying a script to abstract away all 
the complexities. Here we do just that by including our very simple 
[app-manage script](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/app-manage) and setting our 
[pre_start](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L9), 
[command](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L11), 
[healthcheck](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L19) and 
[reload](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L12) variables.

For our effective orchestration our application is going to need to know about other applications on which it depends. In the 
case of Apache, that is Squid; and Squid registers as a 
[service called squid-gcp-proxy](https://github.com/mesoform/squid-gcp-proxy/blob/master/defaults/main.yml#L3) in Consul (note, 
this links to the project_name of the Squid repository). So we add that to our 
[upstreams list](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L31). Then we add some logic into our 
[Apache forward proxy configuration template](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/fwdproxy.conf.ctmpl)
 and our [reverse template](https://github.com/mesoform/apache-fwdproxy/blob/master/templates/app/rvrsproxy.conf.ctmpl.j2), so 
 that [consul-template](https://github.com/hashicorp/consul-template) can 
 [(re)configure our application](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/app-manage#L42) on 
 [startup](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L49) and if there are any 
 [changes](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L138) to our upstream Squid proxy. 
