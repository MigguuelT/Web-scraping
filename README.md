## Tutorial de Web Scraping e Transformação de Dados em R e Python

Este tutorial descreve um fluxo de trabalho completo de Web Scraping para extrair dados tabulares de um site, complementar as informações por meio de raspagem de páginas detalhadas e, em seguida, enriquecer os dados criando uma nova coluna usando o mapeamento de um dicionário. O processo utiliza as linguagens de programação R e Python com suas bibliotecas de manipulação de dados.

O objetivo do fluxo de trabalho apresentado nos scripts é:

1.  **Extrair a Tabela Principal (R):** Baixar a tabela de Terras Indígenas (TIs) da página principal usando o R e salvar em um arquivo CSV.
2.  **Complementar com Informações Detalhadas (Python):** Para cada TI na tabela, visitar sua página de detalhes para extrair a sigla da Unidade Federativa (UF), que não estava na tabela principal, e adicionar essa informação em uma nova coluna.
3.  **Enriquecer os Dados (Python/Pandas):** Usar um dicionário de mapeamento para traduzir a sigla da UF para o nome completo do estado em uma nova coluna (`Estados`).

### Passo 1: Extração da Tabela Principal com R (`Extrair infos via seletor CSS.R`)

O primeiro passo é obter os dados da tabela principal do site usando a biblioteca `rvest` do R.

**Atenção: A Importância da Inspeção de Elementos**

Para que o *web scraping* funcione, é **crucial inspecionar o código-fonte HTML** da página-alvo. O seletor CSS é como um endereço para a informação que você deseja extrair. Neste caso, a tabela foi identificada com o seletor `"table.table.table-striped.tablesorter"`.

O script R realiza as seguintes ações:

  * **Instala e carrega o pacote `rvest`**: Assegura que as ferramentas de web scraping estejam disponíveis.
  * **Define a URL**: `url <- "https://terrasindigenas.org.br/pt-br/brasil"`
  * **Lê o HTML**: Usa `read_html(url)` para baixar o conteúdo da página.
  * **Seleciona a Tabela**: `tabela_node <- html_element(pagina_web, "table.table.table-striped.tablesorter")` utiliza o seletor CSS para apontar exatamente para o elemento da tabela.
  * **Extrai e Converte**: `dados_tabela <- html_table(tabela_node)` transforma o nó HTML da tabela em um *data frame* do R, de forma automática e eficiente.
  * **Salva o CSV**: `write.csv(dados_tabela, "terras_indigenas.csv", row.names = FALSE, fileEncoding = "UTF-8")` salva o resultado.
      * O parâmetro `fileEncoding = "UTF-8"` é importante para garantir que caracteres especiais (como acentos e "ç") sejam salvos corretamente.

### Passo 2: Complementação de Dados com Python (`Web Scraping Terras Indigenas.ipynb`)

O segundo passo envolve iterar sobre a tabela salva para obter as siglas de UF de cada Terra Indígena (TI) em suas respectivas páginas de detalhes, usando as bibliotecas `requests` e `BeautifulSoup` do Python.

O script Python realiza o seguinte:

1.  **Define a Função de Extração de UF**: A função `extrair_uf_da_pagina_detalhe(url_detalhe)` é a chave:

      * Ela recebe a URL da página de detalhes da TI.
      * Envia uma requisição HTTP (`requests.get(url_detalhe)`) com um `User-Agent` para simular um navegador real (boas práticas de raspagem).
      * Usa `BeautifulSoup` para analisar o HTML.
      * Procura por todas as tags `<span>` com a classe `'info-box-number'`, que contêm as siglas de UF.
      * Filtra as siglas válidas e as retorna.
      * **Importante**: Inclui um `time.sleep(1)` entre cada requisição para evitar sobrecarregar o servidor do site (prática de *web scraping* ética).

2.  **Extrai Links e Carrega a Tabela Base**:

      * Acessa a página principal novamente para extrair o link de detalhes de cada TI e armazena em um dicionário (`links_por_nome`).
      * Carrega o arquivo CSV criado no Passo 1: `df = pd.read_csv('terras_indigenas.csv')`.

3.  **Itera e Atualiza a Coluna UF**:

      * O *script* itera sobre cada linha do *data frame* (`for index, row in df.iterrows():`).
      * Para cada TI, ele obtém o URL do dicionário e chama a função de extração, salvando o resultado na nova coluna `'UF'` do *DataFrame*.

4.  **Salva o Novo CSV**: `df.to_csv('terras_indigenas_com_uf.csv', index=False, encoding='utf-8-sig')` salva o arquivo com a nova coluna `'UF'`.

### Passo 3: Enriquecimento dos Dados com Mapeamento em Python (`Adicionar coluna com map.ipynb`)

O último passo é simplificar a análise dos dados transformando as siglas de UF em nomes completos de estados.

  * **Carregar o CSV**: `dados = pd.read_csv("terras_indigenas_com_uf.csv", encoding="utf-8", sep=",")`.

      * **Frisando a Importância de `encoding` e `sep`**: O uso de `encoding="utf-8"` e `sep=","` é vital. O parâmetro `encoding` garante que caracteres especiais sejam lidos corretamente, e o `sep` especifica o delimitador usado no arquivo CSV, evitando problemas de leitura e coluna única.

  * **Criação do Dicionário de Mapeamento**: É criado um dicionário (`mapa_estados`) que relaciona cada sigla de UF (chave) ao seu respectivo nome de estado (valor):

    ```python
    mapa_estados = {
        'AC': 'Acre',
        'AL': 'Alagoas',
        # ... outros estados
        'TO': 'Tocantins'
    }
    ```

  * **Adicionar a Coluna `Estados`**: A função `map()` do *Pandas* aplica o dicionário `mapa_estados` à coluna `UF`, criando a nova coluna `Estados` com os nomes completos:

    ```python
    dados['Estados'] = dados['UF'].map(mapa_estados)
    ```

  * **Salvar o Resultado Final**: `dados.to_csv("terras_indigenas_com_uf_estado.csv", index=False)` finaliza o processo, salvando a tabela completa e enriquecida.
