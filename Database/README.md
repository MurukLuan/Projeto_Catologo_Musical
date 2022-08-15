# **db_discoteca:**
---
Este banco de dados tem objetivo educacional e foi desenvolvido junto aos alunos do curso profissionalizante de DBA.

Abaixo você encontrá uma breve descrição dos objetos implementados neste banco e o script SQL desenvolvido.

---



## **Dados padronizados de cada tabela**
    

Aqui podemos ver as chaves primarias e suas respectivas constraints, também podemos ver as constraints CHECK e valores padrões estabelecidos por DEAFULT em uma coluna da tabela.

    
|TABLES|PRIMARY KEYS|CONSTRAINTS|CONSTRAINT CHECK|DEFAULT VALUES|
|:-|:-:|:-|:-:|:-:|
|gravadora |id_gravadora|PK_id_gravadora|-|Independente|
|artista   |id_artista|PK_id_artista|-|Desconhecido|
|genero|id_genero|PK_id_genero|-|- Outros|
|disco|id_disco|PK_id_disco|-|0|
|musica|id_musica| PK_id_musica|CK_tempo_musica|-|

## **Chaves estrangeiras e seus relacionamentos**

|FOREIGN KEYS|CONSTRAINT|RELATIONS|
|-|-|-|
|id_gravadora|FK_id_gravadora|disco - gravadora|
|id_artista|FK_id_artista|disco  - artista|
|id_genero|FK_id_genero|disco  - genero|
|id_disco|FK_id_disco|musica - disco|

## **TRIGGERS** 
- TR_tempo_disco_insert
    - automatiza o tempo total do disco contabilizando pela soma do tempo de musicas cadastradas
- TR_tempo_disco_update 
    - automatiza o tempo total do disco contabilizando pela soma do tempo de musicas cadastradas


##	**VIEWS**
- **VW_dados_disco**
    - disponibiliza os dados completos do disco ja integrando sua gravadora e artista;
- **VW_musicas**
    - exibe as musicas ja com o nome do seu respectivo disco e artista;
- **VW_artistas**
    - exibe nome e idade dos artistas acompanhados de quantos discos cada um possui cadastrados;
- **VW_gravadora**
    - exibe o nome de cada gravadora e a quantidade de discos de cada uma;

##	**FUNCTIONS**
- **FN_maiuscula**
    - Converte em maiuscula a primeira letra de cada palavra em uma string

## **PROCEDURES**
- **SP_insert_gravadora**
    - insere uma nova gravadora       

 **PARAMETROS**

- SP_insert_gravadora (g_nome);
    - g_nome  ---- sera o nome da gravadora a ser inserida.
        
**EXEMPLO DE USO**

```sql
CALL SP_insert_gravadora('UNIVERSAL');
```
---
- **SP_insert_genero**
    - insere um novo genero musical       

 **PARAMETROS**

- SP_insert_genero (ge_nome);
    - ge_nome 	----- sera o nome do genero a ser inserido.
        
**EXEMPLO DE USO**

```sql
CALL SP_insert_genero('Rock');
```
---

- **SP_insert_artista**
    - insere um artista      

 **PARAMETROS**

- SP_insert_artista (a_nome , nascimento);
    - a_nome         ------- deve ser o nome do artista,
    -	nascimento     ------- deve ser sua data de nascimento no formato 'YYYY-MM-DD'
        
**EXEMPLO DE USO**

```sql
CALL SP_insert_artista('Luciano', '1993-09-09');
```
---

- **SP_insert_disco**
    - insere um disco      

 **PARAMETROS**

- SP_insert_disco (d_titulo, ano, cod_artista, cod_gravadora, cod_genero, cod_disco);
    -	d_titulo		------titutlo do disco a ser inserido
    -	ano				------ano de lancamento do disco a ser inserido
    -	cod_artista		------codigo do artista do disco
    -	cod_gravadora	------codigo da gravadora responsavel pelo disco
    -	cod_genero		------codigo do genero do disco
    -	cod_disco		------codigo geredo para o disco apos o seu cadastro
        
**EXEMPLO DE USO**

Aqui vale uma atenção, esta procedure possui o campo cod_disco, sendo um campo de saida, este campo retornará o id do disco cadastrado pela procedure.
Este campo pode ser acessado da sequinte forma:

```sql
CALL SP_insert_disco ('Forro do BOM', '1993','3','3','3',@id);
SELECT @id;
```
- @id é uma variavel temporaria criada apenas pra receber o retorno da procedure.

- SELECT @id; Com esse comnado podemos acessar o conteudo da variavel de saida

Caso não queira visualizar o retorno basta usar a procedure da seguinte forma:


```sql
CALL SP_insert_disco ('Forro do BOM', '1993','3','3','3');
```
---

- **SP_insert_musica**
    - insere uma música      

 **PARAMETROS**

- SP_insert_musica (titulo , duracao , cod_disco );
    - titulo		----- nome da musica a ser inserida
    - duracao		----- tempo de duração de uma musica
    - cod_disco	----- aqui deve ser inserido o codigo do disco ao qual pertence a musica
    
**EXEMPLO DE USO**

```sql
CALL SP_insert_musica('cada um no seu quadrado', '4.2','3');
```
---