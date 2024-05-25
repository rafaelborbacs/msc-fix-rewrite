FROM elixir:1.13

# Apt
RUN apt-get clean all -y
RUN apt-get dist-upgrade -y
RUN apt update --fix-missing&& apt upgrade -y
RUN apt install -y apt-utils
RUN apt install -y build-essential
RUN apt install -y inotify-tools
RUN apt install -y postgresql-client
RUN apt install -y dcmtk
RUN apt install -y openssh-client
RUN apt install -y rsync
RUN apt install -y python3 python3-pip
RUN pip3 install pydicom
RUN echo "    StrictHostKeyChecking no" >>/etc/ssh/ssh_config
RUN echo "    UserKnownHostsFile=/dev/null" >>/etc/ssh/ssh_config

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app

CMD ["/app/entrypoint.sh"]
