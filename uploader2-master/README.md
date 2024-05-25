# DCMUPLOADER

> Sistema que facilita o envio seguro e ágil de imagens médicas entre LANs de hospitais.

## 🚀 Instalando o DCMUPLOADER

Em uma ordem específica, implante os componentes do projeto usando o Docker Compose. Obtenha detalhes sobre a implantação no manual de cada componente;
1. Faça a implantação do PACS de destino;
2. Faça a implantação do Uploader G;
3. Faça a implantação do Uploader R;
4. Faça a implantação do Uploader T;

Agora, basta aguardar a configuração. Quando o Uploader T estiver pronto, estará disponível na porta 4000 do respectivo host.

...

Em breve um guia de opções de configuração será fornecido.

Procedimento análogo se aplica aos demais componentes do projeto.

## ☕ Usando o DCMUPLOADER

Para usar o DCMUPLOADER, siga essas etapas

<!-- 1. Configure o Uploader T, informando principalmente os dados do Uploader R associado
2. Configure o Uploader R, informando principalmente os dados do Repositório DICOM associado
3. Envie um arquivo DICOM utilizando um C-STORE SCP para a porta 6000 do Uploader T.
4. Se tudo estiver bem configurado, você deve poder ver o estudo DICOM enviado no repositório de destino! -->

- No Uploader R, configure "Config. do Uploader R" e "Config. do Repositório" para que o Uploader R saiba onde enviar os estudos DICOM;
- Configure o PACS de destino para aceitar conexões do Uploader R, usando as configurações informadas no passo anterior, que incluem AE Title do Uploader R;
- No Uploader T, configure "Configuração de Origem" e "Configuração de Destino" para que o Uploader T saiba onde enviar os estudos DICOM
- No Uploader G autorize primeiramente o R a se vincular à rede. Em seguida, permita que o T se vincule à rede;
- Nos detalhes do R, aceite a solicitação de vinculação direta do T
- Envie um estudo DICOM para o Uploader T, usando o C-STORE SCP da porta 6000 do Uploader T;
- Depois do processamento, verifique se o estudo DICOM foi enviado para o PACS de destino.

## Uma vez implantado, como obter atualizações do software?

> Vá até a pasta principal, que contém as pastas de instalação de cada módulo do sistema.  Se você estiver na pasta 'uploader_*' e quiser voltar para a pasta raiz do projeto, utilize o comando `cd ..`
```
git pull
cd ../uploader_g
sudo docker-compose up --build -d
cd ../uploader_r
sudo docker-compose up --build -d
cd uploader_t
sudo docker-compose up --build -d
```
 
[⬆ Voltar ao topo](#nome-do-projeto)<br>