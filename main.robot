*** Settings ***
Library          Collections
Library          SeleniumLibrary
Library          OperatingSystem
Library          seguranca.py
Suite Teardown   Limpar Screenshots

*** Variables ***
## CONTA / AUTENTICAÇÃO
${URL}                                 %{CANVAS_URL}
${LOGIN_EMAIL}                         %{CANVAS_LOGIN}
${SENHA_CRYPT}                         %{CANVAS_SENHA_CRYPT}
${SENHA_SEED}                          %{CANVAS_SENHA_SEED}
${APAGAR_SCREENSHOTS}                  %{APAGAR_SCREENSHOTS=True}

# Botão/link de entrada na tela inicial do Canvas
${LOGIN_INICIAL_BOTAO}                 xpath=/html/body/div/div/div/div[2]/div[3]/div[1]/h2/button
${LOGIN_INICIAL_BOTAO_2}               xpath=//h2/button
${LOGIN_SUB}                           xpath=/html/body/div/div/div/div[2]/div[3]/div[1]/div/div/a
${LOGIN_SUB_2}                         xpath=//a[contains(@href,'microsoftonline')]
${LOGIN_SUB_3}                         xpath=//a[contains(@href,'saml')]
${TEXTBOX_LOGIN}                       xpath=//*[@id="i0116"]
${BOTAO_LOGIN_EMAIL}                   xpath=//*[@id="idSIButton9"]
${TEXTBOX_SENHA}                       xpath=//*[@id="i0118"]
${BOTAO_LOGIN_SENHA}                   xpath=//*[@id="idSIButton9"]

## DASHBOARD / CURSOS GENÉRICOS
${DASHBOARD_CONTAINER}                 xpath=//*[@id="DashboardCard_Container"]
${DASHBOARD_NAV_LINK}                  xpath=//*[@id="global_nav_dashboard_link"]
${CARD_MATERIA_LINK}                   xpath=//*[@id="DashboardCard_Container"]//div[contains(@class,'ic-DashboardCard')]//a[contains(@class,'ic-DashboardCard__link')]

## ELEMENTOS INTERNOS DA MATÉRIA E MÓDULOS
# Busca a primeira tag (a) relativa a um ícone de não concluído na listagem de módulos
${PRIMEIRO_NAO_CONCLUIDO}              xpath=(//i[contains(@class, 'icon-mark-as-read')]/ancestor::li//a[contains(@class, 'title') or contains(@class, 'ig-title')])[1]

${BOTAO_FEITO}                         xpath=//*[@id="mark-as-done-checkbox"]
${BOTAO_PROXIMO_1}                     xpath=//*[@id="module_navigation_target"]/div/div[2]/div/div[2]/span[2]/span/a
${BOTAO_PROXIMO_2}                     xpath=//*[@id="sequence_footer"]/div[2]/div/div[2]/span/span/a
${BOTAO_PROXIMO_3}                     xpath=//*[@id="module_sequence_footer"]/div[2]/div/div[2]/span/span/a

*** Keywords ***
Limpar Screenshots
    [Documentation]    Fecha os navegadores e apaga imagens .png e htmls de erro ao final da execução se APAGAR_SCREENSHOTS for True
    Run Keyword And Ignore Error    Close All Browsers
    ${deve_apagar}=    Convert To Boolean    ${APAGAR_SCREENSHOTS}
    IF    ${deve_apagar}
        Log    Removendo screenshots e arquivos de erro gerados durante a suíte...
        Run Keyword And Ignore Error    Remove Files    ${CURDIR}/selenium-screenshot-*.png    ${CURDIR}/pagina_erro.html
    END

Clicar Com JS
    [Arguments]    ${locator}
    [Documentation]    Clica no elemento usando JavaScript para evitar ElementClickInterceptedException.
    Wait Until Page Contains Element    ${locator}    15s
    ${element}=    Get WebElement    ${locator}
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${element}

Esperar Elemento
    [Arguments]    ${timeout}    @{locators}
    [Documentation]    Espera até UM dos locators aparecer na página; devolve o primeiro encontrado.
    ${timeout_int}=    Convert To Integer    ${timeout}
    ${end_time}=    Get Time    epoch
    ${end_time}=    Evaluate    ${end_time} + ${timeout_int}
    WHILE    True
        FOR    ${locator}    IN    @{locators}
            ${achou}=    Run Keyword And Return Status    Page Should Contain Element    ${locator}
            IF    ${achou}
                RETURN    ${locator}
            END
        END
        ${now}=    Get Time    epoch
        IF    ${now} >= ${end_time}
            BREAK
        END
        Sleep    1s
    END
    Log Textos Da Pagina
    Fail    Nenhum dos locators apareceu em ${timeout}s:\n@{locators}

Esperar E Clicar
    [Arguments]    ${timeout}    @{locators}
    [Documentation]    Espera UM dos locators aparecer e clica nele via JS.
    ${locator}=    Esperar Elemento    ${timeout}    @{locators}
    Clicar Com JS    ${locator}

Log Textos Da Pagina
    [Documentation]    Lista botões/links visíveis e salva o HTML atual para diagnóstico.
    ${textos}=    Execute JavaScript    var r=[]; document.querySelectorAll('button,a,input,label,h1,h2').forEach(function(e){ var t=(e.innerText||e.textContent||'').trim().replace(/\\s+/g,' '); if(t && r.indexOf(t)<0){ r.push(t);} }); return r.slice(0,80).join(' | ');
    Log    Textos encontrados na página:\n${textos}
    ${fonte}=    Get Source
    Create File    ${CURDIR}/pagina_erro.html    ${fonte}

Abrir Site Modo Invisivel
    [Documentation]    Acessa o portal Canvas institucional e faz login caso necessário
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Create Webdriver    Chrome    options=${options}
    Go To    ${URL}
    Maximize Browser Window
    Sleep    3

    # Verifica se já está autenticado (Painel de Controle já visível)
    ${ja_logado}=    Run Keyword And Return Status    Page Should Contain Element    ${DASHBOARD_CONTAINER}
    IF    ${ja_logado}
        Log    Usuário já está autenticado no Canvas.
        RETURN
    END

    # Caso precise de login
    ${ms_direto}=    Run Keyword And Return Status    Page Should Contain Element    ${TEXTBOX_LOGIN}
    IF    not ${ms_direto}
        ${tem_botao}=    Run Keyword And Return Status    Page Should Contain Element    ${LOGIN_INICIAL_BOTAO_2}
        IF    ${tem_botao}
            Esperar E Clicar    15    ${LOGIN_INICIAL_BOTAO}    ${LOGIN_INICIAL_BOTAO_2}
            Sleep    2
            Esperar E Clicar    15    ${LOGIN_SUB}    ${LOGIN_SUB_2}    ${LOGIN_SUB_3}
        END
    END

    Wait Until Page Contains Element    ${TEXTBOX_LOGIN}    30s
    Input Text    ${TEXTBOX_LOGIN}    ${LOGIN_EMAIL}
    Clicar Com JS    ${BOTAO_LOGIN_EMAIL}
    Sleep    3

    Wait Until Page Contains Element    ${TEXTBOX_SENHA}    30s
    ${senha}=    Descriptografar Senha    ${SENHA_CRYPT}    ${SENHA_SEED}
    Input Text    ${TEXTBOX_SENHA}    ${senha}
    Clicar Com JS    ${BOTAO_LOGIN_SENHA}
    Sleep    3

    ${perm_conectado}=    Run Keyword And Return Status    Page Should Contain Element    ${BOTAO_LOGIN_SENHA}
    IF    ${perm_conectado}
        Clicar Com JS    ${BOTAO_LOGIN_SENHA}
        Sleep    3
    END

    Wait Until Page Contains Element    ${DASHBOARD_CONTAINER}    45s

Voltar Ao Dashboard
    [Documentation]    Retorna ao Painel de Controle (Dashboard) do Canvas
    Clicar Com JS    ${DASHBOARD_NAV_LINK}
    Wait Until Page Contains Element    ${DASHBOARD_CONTAINER}    30s
    Sleep    3

Obter Lista De Cursos
    [Documentation]    Coleta as URLs de TODOS os cursos presentes no Dashboard (DashboardCards).
    Wait Until Page Contains Element    ${DASHBOARD_CONTAINER}    45s
    Sleep    3
    ${hrefs}=    Create List
    ${elements}=    Get WebElements    ${CARD_MATERIA_LINK}
    ${qtd}=         Get Length    ${elements}
    Log    Encontrados ${qtd} cursos no painel inicial.

    FOR    ${el}    IN    @{elements}
        ${href}=    Get Element Attribute    ${el}    href
        ${tem_href}=    Run Keyword And Return Status    Should Not Be Empty    ${href}
        IF    ${tem_href}
            # limpa parâmetros e paths extras para pegar a raiz do curso
            ${href_unico}=    Evaluate    '${href}'.split('?')[0]
            ${ja_existe}=    Evaluate    '${href_unico}' in ${hrefs}
            IF    not ${ja_existe}
                Append To List    ${hrefs}    ${href_unico}
            END
        END
    END
    RETURN    ${hrefs}

Avançar Para Proximo Passo
    [Documentation]    Checa os diferentes locators do botão Próximo do Canvas e avança se existir.
    ${p1}=    Run Keyword And Return Status    Page Should Contain Element    ${BOTAO_PROXIMO_1}
    IF    ${p1}
        Clicar Com JS    ${BOTAO_PROXIMO_1}
        Sleep    5
        RETURN    True
    END

    ${p2}=    Run Keyword And Return Status    Page Should Contain Element    ${BOTAO_PROXIMO_2}
    IF    ${p2}
        Clicar Com JS    ${BOTAO_PROXIMO_2}
        Sleep    5
        RETURN    True
    END

    ${p3}=    Run Keyword And Return Status    Page Should Contain Element    ${BOTAO_PROXIMO_3}
    IF    ${p3}
        Clicar Com JS    ${BOTAO_PROXIMO_3}
        Sleep    5
        RETURN    True
    END

    RETURN    False

Processar Loop Feito Proximo
    [Documentation]    Uma vez dentro de um item da matéria, clica em 'Marcar como concluído' (se não estiver) e vai para o 'Próximo'.
    FOR    ${i}    IN RANGE    1    100
        ${feito_existe}=    Run Keyword And Return Status    Page Should Contain Element    ${BOTAO_FEITO}
        IF    ${feito_existe}
            ${estado_feito}=    Get Element Attribute    ${BOTAO_FEITO}    data-is-checked
            IF    '${estado_feito}' == 'false'
                Clicar Com JS    ${BOTAO_FEITO}
                Sleep    3
            END
        END

        ${avancou}=    Avançar Para Proximo Passo
        Exit For Loop If    not ${avancou}
    END

Processar Uma Materia
    [Arguments]    ${curso_url}
    [Documentation]    Acessa a aba de Módulo do curso corrente, encontra o primeiro icon-mark-as-read e processa até o final.
    Log    Acessando curso: ${curso_url}
    ${curso_url_base}=    Evaluate    '${curso_url}'.replace('/modules', '')
    Go To    ${curso_url_base}/modules
    Sleep    5

    # Procura na lista de Módulos (unidades) o 1° item que possui a classe de não-concluído
    ${existe_nao_concluido}=    Run Keyword And Return Status    Page Should Contain Element    ${PRIMEIRO_NAO_CONCLUIDO}

    IF    ${existe_nao_concluido}
        Log    Item não concluído encontrado! Acessando conteúdo corrente.
        Clicar Com JS    ${PRIMEIRO_NAO_CONCLUIDO}
        Sleep    5
        Processar Loop Feito Proximo
    ELSE
        Log    Nenhum item não concluído ('icon-mark-as-read') encontrado nesta disciplina.
    END

    Voltar Ao Dashboard

Processar Todas As Materias
    [Documentation]    Descobre dinamicamente os cursos disponíveis no painel e processa todos eles.
    ${cursos}=    Obter Lista De Cursos
    FOR    ${curso}    IN    @{cursos}
        # Tenta continuar os próximos cursos mesmo que um deles dê timeout ou falhe gravemente
        Run Keyword And Ignore Error    Processar Uma Materia    ${curso}
    END

*** Test Cases ***
Executar Automação
    Abrir Site Modo Invisivel

Abrir Todas As Materias
    Processar Todas As Materias
