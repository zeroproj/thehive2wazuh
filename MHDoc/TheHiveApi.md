# Preparando o TheHive

Voce pode encontrar a docmentação original aqui:

[Documentação Wazuh e TheHive](https://wazuh.com/blog/using-wazuh-and-thehive-for-threat-protection-and-incident-response/)

Criamos uma nova organização na interface web do TheHive com uma conta de administrador.

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/01.png?raw=true)

Na organização de teste, criamos um novo usuário com privilégios de administrador da organização.

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/02.png?raw=true)

Organização de Teste do TheHive
Esse usuário tem permissões para gerenciar a organização, incluindo a criação de novos usuários, o gerenciamento de casos e alertas, entre outras funções. Também criamos uma senha para esse usuário, para que possamos fazer login, visualizar o painel e gerenciar casos. Isso é feito clicando em "Nova senha" ao lado da conta do usuário e inserindo a senha desejada.

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/03.png?raw=true)

Clique em "Nova senha" ao lado da conta do usuário e insira a senha desejada
A integração com o Wazuh é possível com a ajuda da API REST do TheHive. Portanto, precisamos de um usuário no TheHive que possa criar alertas por meio da API. Criamos uma conta com privilégio de "analista" para esse fim.

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/04.png?raw=true)

Criamos uma conta com o privilégio de "analista" para esse fim

Para a próxima etapa, geramos a chave da API para o usuário:

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/05.png?raw=true)


Para a próxima etapa, geramos a chave da API para o usuário

![THEHIVE](https://github.com/zeroproj/MHSoc/blob/main/MHDoc/MHIMG/06.png?raw=true)

Para extrair a chave da API, revelamos a chave para visualizá-la e copiá-la para uso futuro:

Revelamos a chave para visualizá-la e copiá-la para uso futuro