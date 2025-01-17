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

1) Crie um grupo para o usuário do serviço:

Nome sugerido: oci-ssl-ctl-group

2) Crie uma conta de usuário e adicione essa conta de usuário no grupo criado no passo anterior.

Nome sugerido: oci-ssl-ctl-user

Ajustes Sugestões:

- Desmarque o opção "Use the email address as the username"
- Use uma conta de e-mail valida para receber eventuais notificações da OCI para esse usuário.
- Em "Edit user capabilities" deixe habilitando somente o "API Keys" removendo assim acessos desnecessários.
 
3) Crie uma API Key para o usuário oci-ssl-ctl-user e salve a chave privada e finger print com muito cuidado, pois essas informações sensiveis serão usadas nos passos seguintes.

4)  Em "Identity & Security" > "Policies" crie uma nova política com o nome oci-ssl-ctl-policies e adicione as seguintes regras. Se preferir substitia o contexto "in tenancy" pelos compartments correspondentes:

Allow group Default/oci-ssl-ctl-group to inspect certificate-authority-family in Tenancy  
Allow group Default/oci-ssl-ctl-group to use certificate-authority-delegate in Tenancy  
Allow group Default/oci-ssl-ctl-group to manage leaf-certificate-family in Tenancy  
Allow group Default/oci-ssl-ctl-group to use dns in Tenancy  

Os demais passos  procedimento de instação leva em consideração ums máquina virtual usando Oracle Linux 9


5 - 


