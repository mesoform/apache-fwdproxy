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
example we demonstrate this by
[compiling Apache in one script](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/compile.sh) and performing
[other activities in another](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/install.sh). We 
also drop any Jinja2 templates into the [templates/app directory](https://github.com/mesoform/apache-fwdproxy/tree/master/templates/app).

In this paradigm, orchestration is the responsibility of the applications owners (who know best how it should operate) and 
executed by [Containerpilot](https://github.com/joyent/containerpilot) running inside the container. Orchestration can be as 
simple as passing commands to start and reload the application but also more powerful by supplying a script to abstract away all 
the complexities. Here we do just that by including our very simple 
[app-manage script](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/app-manage) and setting our 
[pre_start](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L25), 
[command](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L27), 
[healthcheck](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L24) and 
[reload](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L28) variables.

NB. All scripts are installed into /usr/local/bin inside the container all configuration into /etc/apache-fwdproxy (the name of
our project)

For our effective orchestration our application is going to need to know about other applications on which it depends. In the 
case of Apache, that is Squid; and Squid registers as a 
[service called squid-gcp-proxy](https://github.com/mesoform/squid-gcp-proxy/blob/master/defaults/main.yml#L3) in Consul (note, 
this links to the project_name of the Squid repository). So we add that to our 
[upstreams list](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L29). Then we add some logic into our 
[Apache forward proxy configuration template](https://github.com/mesoform/apache-fwdproxy/blob/master/templates/app/fwdproxy.conf.ctmpl.j2)
 and our [reverse template](https://github.com/mesoform/apache-fwdproxy/blob/master/templates/app/rvrsproxy.conf.ctmpl.j2), so 
 that [consul-template](https://github.com/hashicorp/consul-template) can 
 [(re)configure our application](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/app-manage#L42) on 
 [startup](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L49) and if there are any 
 [changes](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L138) to our upstream Squid proxy. 

Finally, we set some [more operating variables](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L16-L30),
[default container environment variables](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L33), 
[wider system environment variables](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L35) (we don't really use
any) and [variables we need for our install scripts](https://github.com/mesoform/apache-fwdproxy/blob/master/vars/main.yml#L9-L14).

When we run `ansible-playbook -v app.yml` Ansible performs the following actions:
1. Creates `files/etc/apache-fwdproxy` (because initially it doesn't exist)
1. Processes the files with a `.j2` extension in `templates/app` through the Jinja2 template engine, modifies them if required and 
copies them (minus `.j2` extension) to `files/etc/apache-fwdproxy`
1. Generates our `docker-compose.yml` and `containerpilot.json5` orchestration files based on our provided variables. Then places 
`containerpilot.json5` in `files/etc` and `docker-compose.yml` in the top level playbook directory.
1. Generates a standardised Dockerfile from the 
[Mesoform Debian base image](https://hub.docker.com/r/mesoform/concierge-debian-base-image/) and copies it to the Docker build 
directory `files/`
1. Builds and tags a Docker image
1. Generates a basic Docker Compose file for our integration services (Consul and Zabbix)
1. Lastly, we've manually dropped the Compose file into the root directory for Squid. We may make upstreams a map which includes 
the image and automate this at some point.

Once finished, if there were any changes to upstream sub-modules, then you'll get a message, so look out for these if there are
any issues. Then the only that remains is to orchestrate your application. This also is currently manual but will be included 
in the playbook soon.

```docker-compose -f docker-compose-integrations.yml -f docker-compose.yml -f docker-compose-app-integrations.yml up```

You can log into the containers and look how the configuration happened but you'll also find the events in the logs.

Next, lets get the mapped port address of Apache (local Docker deployment) and grab the mapped port for `33000`
```bash
(gaz@gMac)-(21:07:23)-(test)
$docker ps
CONTAINER ID        IMAGE                                          COMMAND                  CREATED             STATUS                    PORTS                                                                                                                                                                                                      NAMES
44338060c8b3        mesoform/concierge-squid-gcp-proxy:0.1.0       "/usr/local/bin/cont…"   29 seconds ago      Up 26 seconds (healthy)   3128/tcp, 10050/tcp                                                                                                                                                                                        apachefwdproxy_squid-gcp-proxy_1
482c7122532f        mesoform/concierge-apache-fwdproxy:ver-0.1.0   "/usr/local/bin/cont…"   29 seconds ago      Up 26 seconds (healthy)   0.0.0.0:32908->10050/tcp, 0.0.0.0:32907->33000/tcp                                                                                                                                                         apachefwdproxy_app_1
a0a3375c1813        mesoform/concierge-consul:devtest              "/bin/containerpilot…"   29 seconds ago      Up 27 seconds             53/tcp, 10050/tcp, 53/udp, 0.0.0.0:32906->8300/tcp, 0.0.0.0:32809->8301/udp, 0.0.0.0:32905->8301/tcp, 0.0.0.0:32808->8302/udp, 0.0.0.0:32904->8302/tcp, 0.0.0.0:32903->8400/tcp, 0.0.0.0:32902->8500/tcp   apachefwdproxy_consul_1
```

and update our Google Cloud SDK config:

```bash
$grep proxy ~/.boto 
# To use a proxy, edit and uncomment the proxy and proxy_port lines.
# If you need a user/password with this proxy, edit and uncomment
# lookups by client machines set proxy_rdns = True
# If proxy_host and proxy_port are not specified in this file and
# one of the OS environment variables http_proxy, https_proxy, or
# HTTPS_PROXY is defined, gsutil will use the proxy server specified
proxy = localhost
proxy_port = 32907
#proxy_user = <proxy user>
#proxy_pass = <proxy password>
#proxy_rdns = <let proxy server perform DNS lookups>
```

then check it works

```bash
(gaz@gMac)-(21:07:59)-(test)
$gsutil ls
gs://gb-test-bucket-1/
gs://gb-test-bucket-2/
gs://log-storage-bucket/
```

We can also scale Squid and check that the config in the Apache container has updated. Scale Squid by running:

```
$ docker-compose -f docker-compose-integrations.yml -f docker-compose.yml -f docker-compose-app-integrations.yml up -d --scale squid-gcp-proxy=2
``` 

That's pretty much it. Below are some noteworthy points about the configuration if you want to know more. details are covered 
in the concierge-app-playbook readme but we feel these are worth a mention here as well

## Noteworthy configuration 

* We have a custom configuration option called proxy_mode which is set to forward. This is an option only specific to Apache and
 will configure in forward mode but if set to reverse, will configure in reverse mode. Reverse mode isn't much use in our Google 
 API example but it is so simple to implement that we added it so as to allow easy reuse.
* The command variable is set to the raw command and not a function of the app-manage script, simply to demonstrate another way.
* When an upstream service goes healthy for the first time, Containerpilot emits a [healthy _and_ a 
changed](https://github.com/joyent/containerpilot/blob/master/docs/30-configuration/35-watches.md) event. So, to prevent a race 
condition between our application [starting](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L48)
and [reloading]https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L119, we add [functionality
 to account for it](https://github.com/mesoform/apache-fwdproxy/blob/master/files/bin/app-manage#L27-L38).  Applications other 
 Apache don't seem to suffer the same issue of its `graceful` command starting the application in an odd manner.
* The main application command is configured as a container environment variable and read by Containerpilot. We've done this so 
that it is easy to set a `COMMAND` environment variable in your docker-compose.yml file to override the value [built into the
image in the Dockerfile](https://github.com/mesoform/apache-fwdproxy/blob/master/files/Dockerfile#L18); or by querying 
[containerpilot's control plane](https://github.com/joyent/containerpilot/blob/master/docs/30-configuration/37-control-plane.md#putenv-post-v3env)
* Containerpilot can be bypassed all together and you application started on it's own by simply uncommenting the [entrypoint
option in docker-compose.yml](https://github.com/mesoform/apache-fwdproxy/blob/master/docker-compose.yml#L32)
* In this example we only have one upstream. However, we understand that sometimes the will be more than one. Therefore we have 
made upstreams a list where the last service in that list will be the one which our application []waits on before 
starting](https://github.com/mesoform/apache-fwdproxy/blob/master/files/etc/containerpilot.json5#L50-L52) (requires pre_start to
be set).