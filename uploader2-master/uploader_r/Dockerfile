FROM elixir:1.13


# Apt
RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y apt-utils
RUN apt install -y build-essential
RUN apt install -y inotify-tools
RUN apt install -y postgresql-client
# RUN apt install -y dcmtk
RUN apt install -y openssh-server

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# RUN apt-get install dialog -y

# DCM4CHE STORESCU
RUN apt-get install -y default-jdk maven
RUN wget https://ufpr.dl.sourceforge.net/project/dcm4che/dcm4che3/5.28.0/dcm4che-5.28.0-bin.zip
RUN unzip dcm4che-5.28.0-bin.zip
ENV PATH="/dcm4che-5.28.0/bin:${PATH}"

RUN mkdir -p /etc/ssh
COPY ./app/sshd_config /etc/ssh/sshd_config
RUN apt install openssh-server rsync -y

RUN useradd -m -d /home/uploader_t_1 -s /bin/bash uploader_t_1
RUN mkdir -p /home/uploader_t_1/.ssh
RUN chmod 700 /home/uploader_t_1/.ssh
RUN touch /home/uploader_t_1/.ssh/authorized_keys
RUN chmod 640 /home/uploader_t_1/.ssh/authorized_keys
RUN update-rc.d ssh defaults
RUN chmod -R go= /home/uploader_t_1/.ssh
RUN chown uploader_t_1.uploader_t_1 /home/uploader_t_1/.ssh -R

RUN service ssh restart

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app

# COPY ./app/mix.exs .
# COPY ./app/mix.lock .
# COPY ./app .

# RUN mix deps.get 
# RUN mix ecto.create
# RUN mix do compile

# CMD ["mix", "phx.server"]
# CMD mix phx.server

CMD ["/app/entrypoint.sh"]
