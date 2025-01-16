# oci-ssl-ctl


## Sobre o Script

O oci-ssl-ctl é um script shell que pode ser usado como ponto de partida para automatizar o processo de emissão e renovação de Certificados SSL Let's Encrypt integrandos ao serviço Certificates da OCI - Oracle Cloud Infraestructure.

## Como funciona

O oci-ssl-ctl.sh utiliza a ferramenta CertBot para integragir com as autoridades certificadoras e promover a emissão e renovação de certificados, por padrão é usada a Let's Encrypt, mas também é possível realizar a emissão de certificados com outras autoridades certificadoras que usam o protocolo ACME.

Para que seja possível a validação dos domínios o Certbot usará um desafio do tipo DNS e o plugin escolhido para essa integração foi o certbot-dns-multi por suportar os principais serviços de DNS, como OCI DNS, AWS Route53, Azure DNS, CloudFlare, entre vários outros.

Após o processo de emissão ou renovação do certificado usando o Certbot + Plugin certbot-dns-multi usamos a OCI-CLI para fazer o upload do certificado para o serviço OCI Certificates.


## Isenção de responsabilidade

Antes de continuar tenha em mente que a utilização de qualquer script, código ou comandos contidos nesse reposítório é de sua total responsabilidade, não cabendo aos autores dos códigos nenhum ônus sobre qualquer a utilização do conteúdo aqui disponível.

Teste adequadamente todo o conteúdo em ambiente apropriado e integre os scripts de automação a uma infraestrutura de monitoramento, para que seja possível monitorar o funcionamento do processo de automação e para mitigar possíveis falhas que podem ocorrer.

Este não é um aplicativo oficial da Oracle e por isso, não conta com o seu suporte. A Oracle não se responsabiliza por nenhum conteúdo aqui presente.

## Procedimento de Instalação
