*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported SeleniumLibrary.
Library           SeleniumLibrary

*** Variables ***
${SERVER}         localhost:5173
${BROWSER}        chrome
${DELAY}          0.1
${VALID USER}     1
${VALID PASSWORD}    123
${LOGIN URL}      http://${SERVER}/
${WELCOME URL}    http://${SERVER}/
${ERROR URL}      http://${SERVER}/

*** Keywords ***
Open Browser To Login Page
    Open Browser    ${LOGIN URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Login Page Should Be Open

Login Page Should Be Open
    Title Should Be    POSSIBLE

Go To Login Page
    Go To    ${LOGIN URL}
    Login Page Should Be Open

Input Username
    [Arguments]    ${username}
    Wait Until Element Is Visible    css=input[name='username']
    Input Text    css=input[name='username']    ${username}

Input Password
    [Arguments]    ${password}
    Wait Until Element Is Visible    css=input[name='password']
    Input Text    css=input[name='password']    ${password}

Submit Credentials
    Wait Until Element Is Visible    css=button[type='submit']
    Click Button    css=button[type='submit']

Welcome Page Should Be Open
    Location Should Be    ${WELCOME URL}
    Title Should Be    Vite + React

Login Should Have Failed
    Location Should Be    ${ERROR URL}
    Title Should Be    Vite + React
    Page Should Contain    ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง