# Pré-requisitos para implantação do DCMUPLOADER (T)

A implantação do DCMUPLOADER (T) exige um sistema computacional com as
seguintes características:

-   Computador com Linux com pelo menos 2 GB de RAM e processador com
suporte ao recurso de Virtualização com tradução de Segundo Nível (Second Level Address Translation - SLAT);

-   Recurso de Virtualização habilitado na BIOS do computador;

-   Máquina com acesso a internet para obtenção das ferramentas necessárias;

-   Sistema para virtualização de container Docker instalado no sistema operacional;

-   Biblioteca docker-compose instalada no sistema operacional.

Configuração recomendada para instalação do DCMUPLOADER (T) :

-   Máquina virtual 64 bits com 1 CPU virtual com 4 GB de RAM

-   Sistema operacional Ubuntu Server 20.04 LTS

-   Conexão ethernet da máquina virtual com a Internet.
## Configuração do Docker

Para realização da instalação do docker no UBUNTU, o usuário deve
inicialmente se logar diretamente no usuário root. ou se logar em um
usuário com privilégios de administrador (root). Para transformar o
usuários com privilégios de administrador em root, o usuário deve abrir
uma janela do terminal de sua preferência e realizar os seguintes comandos:

  ```
  sudo su
  apt-get update
  apt-get install docker.io docker-compose
  ```

# 4. Instalação do DCMUPLOADER (T)

 ```
git clone https://github.com/toshibamedical/uploader.git
cd software/uploader_t
chmod u+x app/entrypoint.sh
sudo docker-compose up --build -d
```

# 5. Notas finais
Uma vez que esses passos foram realizados o Uploader(T) está disponível para uso. Para acessar o Uploader(T) basta acessar o endereço http://localhost:4000/ no navegador de sua preferência.

## 5.1. Uma vez implantado, como obter atualizações do software?


> Vá até a pasta principal, que contém as pastas de instalação de cada módulo do sistema.  Se você estiver na pasta 'uploader_*' e quiser voltar para a pasta raiz do projeto, utilize o comando `cd ..`
```
git pull
cd uploader_t
sudo docker-compose up --build -d
```


