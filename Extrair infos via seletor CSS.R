# Extrair infos via seletor CSS

# Instalação apenas do pacote
if (!require(rvest)) install.packages(("rvest"))
# Carregndo o pacote
library(rvest)

# 1. Definir a URL da página
url <- "https://terrasindigenas.org.br/pt-br/brasil"

# 2. Ler o conteúdo HTML da página
pagina_web <- read_html(url)

# 3. Selecionar o nó da tabela
# Usamos um seletor CSS para encontrar o elemento com a classe "table-responsive tab-pane active"
# e, dentro dele, a tag <table>.
tabela_node <- html_element(pagina_web, "table.table.table-striped.tablesorter")

# 4. Extrair a tabela e converter para um data frame
# A função html_table() faz isso de forma automática e eficiente.
dados_tabela <- html_table(tabela_node)

# 5. Salvar o data frame em um arquivo CSV
# O arquivo será salvo no seu diretório de trabalho atual.
# usamos row.names = FALSE para não salvar os índices das linhas do R.
# fileEncoding = "UTF-8" é importante para garantir a correta gravação de caracteres especiais.
write.csv(dados_tabela, "terras_indigenas.csv", row.names = FALSE, fileEncoding = "UTF-8")

# Mensagem de confirmação
print("A tabela foi extraída e salva com sucesso no arquivo 'terras_indigenas.csv'")

# Opcional: Visualizar as primeiras linhas da tabela no console do R
head(dados_tabela)
