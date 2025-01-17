# oci-ssl-ctl

## Sobre o Script

O oci-ssl-ctl é um script shell que pode ser usado como ponto de partida para automatizar o processo de emissão e renovação de Certificados SSL Let's Encrypt integrandos ao serviço Certificates da OCI - Oracle Cloud Infraestructure.

## Como funciona

O oci-ssl-ctl.sh utiliza a ferramenta CertBot para interagir com as autoridades certificadoras e promover a emissão e renovação de certificados, por padrão, usando a Let's Encrypt, mas também é possível realizar a emissão de certificados com outras autoridades certificadoras que suportam o protocolo ACME.

Para que seja possível a validação dos domínios o Certbot usará um desafio do tipo DNS. Para essa funcionalidade adotamos o plugin certbot-dns-multi por suportar os principais serviços de DNS, como OCI DNS, AWS Route53, Azure DNS, CloudFlare, entre vários outros.

Após o processo de emissão ou renovação do certificado usando o Certbot + o plugin certbot-dns-multi, utiliza a OCI-CLI para fazer o upload do certificado para o serviço OCI Certificates.


## Isenção de responsabilidade

Antes de continuar tenha em mente que a utilização de qualquer script, código ou comandos contidos nesse reposítório é de sua total responsabilidade, não cabendo aos autores dos códigos nenhum ônus sobre qualquer a utilização do conteúdo aqui disponível.

Teste adequadamente todo o conteúdo em ambiente apropriado e integre os scripts de automação a uma infraestrutura de monitoramento, para que seja possível monitorar o funcionamento do processo de automação e para mitigar possíveis falhas que podem ocorrer.

Este não é um aplicativo oficial da Oracle e por isso, não conta com o seu suporte. A Oracle não se responsabiliza por nenhum conteúdo aqui presente.

## Procedimento de Instalação

Para que o script possa integragir com os serviços OCI Certificates e OCI DNS siga os seguintes passos:

Usando o OCI IAM Identity Domain siga os seguintes passos:

1 - Crie um grupo para o usuário do serviço:

	Nome sugerido: oci-ssl-ctl-group

2 -  Crie uma conta de usuário e adicione essa conta de usuário no grupo criado no passo anterior.

	Nome sugerido: oci-ssl-ctl-user

	Ajustes Sugestões:

	- Desmarque o opção "Use the email address as the username"
	- Use uma conta de e-mail valida para receber eventuais notificações da OCI para esse usuário.
	- Em "Edit user capabilities" deixe habilitando somente o "API Keys" removendo assim acessos desnecessários.
 
3 -  Crie uma API Key para o usuário oci-ssl-ctl-user e salve a chave privada e finger print com muito cuidado, pois essas informações sensiveis serão usadas nos passos seguintes.

4 -  Em "Identity & Security" > "Policies" crie uma nova política com o nome oci-ssl-ctl-policies e adicione as seguintes regras. Se preferir substitia o contexto "in tenancy" pelos compartments correspondentes:

	Allow group Default/oci-ssl-ctl-group to inspect certificate-authority-family in Tenancy  
	Allow group Default/oci-ssl-ctl-group to use certificate-authority-delegate in Tenancy  
	Allow group Default/oci-ssl-ctl-group to manage leaf-certificate-family in Tenancy  
	Allow group Default/oci-ssl-ctl-group to use dns in Tenancy  

Os passos seguintes consideram uma máquina virtual x86 com Oracle Linux 9 

5 - Configuração do TimeZone

	sudo timedatectl set-timezone America/Sao_Paulo  

6 - Atualização dos pacotes do S.O. e após esse processo considere reiniciar o servidor.

	sudo dnf update

7 - Instalação do Python e PIP

	sudo dnf install python3 python3-pip python3-setuptools git -y

8 - Instalação das ferramentas OCI-CLI, Certbot e plugin dns-multi

	pip3 install oci-cli certbot-dns-multi

9 - Faço download 

	sudo git clone https://github.com/phspontes/oci-ssl-ctl.git /opt/oci-ssl-ctl

10 - Ajuste as permissões do diretório conforme seu ambiente

	sudo chown opc:opc /opt/oci-ssl-ctl -R
	sudo chmod 0700 /opt/oci-ssl-ctl -R


11 - Após instalação é preciso preencher as variaveis nos arquivos de configuração:


11.1 - config/global.ini

11.2 - .oci/oci-config

11.3 - .oci/oci_api_key.pem

11.4 - .oci/oraclecloud-dns-multi.ini


Se as zonas de DNS estiverem em outro no AWS Route 53, preencha os sequintes arquivos:

11.5 - .oci/aws-config

11.6 - .oci/route53-dns.multi.ini

12 - Após preencher e validar as informações, crie um arquivo de configuração para o certificado.

No diretório config crie um novo arquivo de configuração para o certificado baseado no cert_template.conf.

	cp config/cert_template.conf config/cert_meuprimeirossl.conf 


Ajuste as variaveis do certificado no novo arquivo conf. E execute o oci-ssl-ctl.sh passando o nome do certificado como parametro:


	cd /opt/oci-ssl-ctl/

	./oci-ssl-ctl.sh meuprimeirossl

Acompanhe a execução do script e no final, um novo certificado ssl será criado no compartment definido no arquivo de configuração do certificado.


13 - Uma vez que o certificado ssl foi criado com sucesso, o processo de renovação consiste em executar novamente o script passando como parametro o nome do certificado.


	cd /opt/oci-ssl-ctl/

	./oci-ssl-ctl.sh meuprimeirossl


14 - E se necessário uma nova versão do certificado será gerada.
