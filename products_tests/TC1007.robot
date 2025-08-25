*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Resource          ../variables.robot

Suite Setup       Open Browser To Login Page
Suite Teardown    Close All Browsers
Test Setup        Login To System

*** Variables ***




*** Test Cases ***

    Create Directory                     ${SCREEN_DIR}

    # 1) ไปหน้า /product และกดปุ่ม “เพิ่มสินค้า”
    Go To                               ${PRODUCT_LIST_URL}
    Wait Until Element Is Visible        ${BTN_ADD_PRODUCT}    ${TIMEOUT}
    Click Element                        ${BTN_ADD_PRODUCT}
    Wait Table Idle

    # 2) ยืนยันว่ามาถึงหน้า /products/create-product
    Ensure On Create Product Page

    # 3) อัปโหลดรูป
    Upload Product Image                 ${PRODUCT_IMAGE_PATH}

    # 4) กรอกข้อมูลฟอร์ม
    Wait Until Element Is Visible        ${INPUT_NAME}    ${TIMEOUT}
    Clear Element Text                   ${INPUT_NAME}
    Input Text                           ${INPUT_NAME}    น้ำยาล้างจาน

    Clear Element Text                   ${INPUT_DESC}
    Input Text                           ${INPUT_DESC}    น้ำยาล้างจานของดี

    Wait Until Element Is Visible        ${SELECT_CATEGORY}    ${TIMEOUT}
    Select From List By Value            ${SELECT_CATEGORY}    ${CATEGORY_VALUE}

    Clear Element Text                   ${INPUT_BARCODE_PACK}
    Input Text                           ${INPUT_BARCODE_PACK}     0150758695519
    Clear Element Text                   ${INPUT_BARCODE_UNIT}
    Input Text                           ${INPUT_BARCODE_UNIT}     0646818912454

    Clear Element Text                   ${INPUT_PACK_SIZE}
    Input Text                           ${INPUT_PACK_SIZE}        12

    Clear Element Text                   ${INPUT_PRICE_UNIT}
    Input Text                           ${INPUT_PRICE_UNIT}       10
    Clear Element Text                   ${INPUT_PRICE_PACK}
    Input Text                           ${INPUT_PRICE_PACK}       120

    Wait Until Element Is Visible        ${INPUT_INIT_QTY}         ${TIMEOUT}
    Clear Element Text                   ${INPUT_INIT_QTY}
    Input Text                           ${INPUT_INIT_QTY}         120

    Clear Element Text                   ${INPUT_INIT_PURCHASE}
    Input Text                           ${INPUT_INIT_PURCHASE}    6

    Clear Element Text                   ${INPUT_INIT_EXPDATE}
    Input Text                           ${INPUT_INIT_EXPDATE}     ${EXPDATE_VALUE}

    # 5) บันทึก
    Click Save Product
    Click If Exists                      ${SWAL_CONFIRM}
    Wait Table Idle


*** Keywords ***
Open Browser To Login Page
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

Login To System
    Wait Until Element Is Visible    css=input[name='username']    ${TIMEOUT}
    Input Text                       css=input[name='username']    ${VALID USER}
    Input Text                       css=input[name='password']    ${VALID PASSWORD}
    Click Button                     css=button[type='submit']
    Wait Table Idle

Ensure On Create Product Page
    ${loc}=         Get Location
    ${on_create}=   Run Keyword And Return Status    Should Be Equal    ${loc}    ${CREATE_URL}
    IF    not ${on_create}
        Go To    ${CREATE_URL}
        Wait Table Idle
    END

Upload Product Image
    [Arguments]    ${filepath}
    # คลิกพื้นที่ "เพิ่มรูปภาพ" เพื่อให้ input[type=file] โผล่ (บาง UI จะสร้างตอนคลิก)
    Wait Until Element Is Visible       ${UPLOAD_CLICK_AREA}    ${TIMEOUT}
    Scroll Element Into View            ${UPLOAD_CLICK_AREA}
    Click Element                       ${UPLOAD_CLICK_AREA}
    Sleep    0.3s
    # หา input[type='file'] ตัวแรกที่มี
    ${file_input}=    Get First Present Locator    ${INPUT_FILE_OPT1}    ${INPUT_FILE_OPT2}
    # เผื่อ hidden: ปลดซ่อนด้วย JS (Choose File มักใช้ได้แม้ hidden แต่กันเหนียว)
    Run Keyword And Ignore Error    Execute Javascript    arguments[0].style.display='block';    ${file_input}
    Run Keyword And Ignore Error    Execute Javascript    arguments[0].removeAttribute('hidden');    ${file_input}
    Choose File                       ${file_input}    ${filepath}
    Wait Table Idle
    Sleep    0.5s

Click Save Product
    ${clicked}=    Run Keyword And Return Status    Click Element    ${BTN_SAVE_OPT1}
    Run Keyword If    ${clicked}    Return From Keyword
    ${has2}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${BTN_SAVE_OPT2}    2s
    Run Keyword If    ${has2}    Click Element    ${BTN_SAVE_OPT2}
    Run Keyword If    ${has2}    Return From Keyword
    ${has3}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${BTN_SAVE_OPT3}    2s
    Run Keyword If    ${has3}    Click Element    ${BTN_SAVE_OPT3}
    Run Keyword If    ${has3}    Return From Keyword
    Fail    ไม่พบปุ่มบันทึกสินค้า (โปรดตรวจสอบ locator ของปุ่มบันทึกในหน้า)

Get First Present Locator
    [Arguments]    @{locators}
    FOR    ${loc}    IN    @{locators}
        ${ok}=    Run Keyword And Return Status    Page Should Contain Element    ${loc}
        IF    ${ok}    RETURN    ${loc}
    END
    Fail    ไม่พบ input[type=file] สำหรับอัปโหลดรูปสินค้า

Wait Table Idle
    Run Keyword And Ignore Error     Wait Until Element Is Not Visible    ${SPINNERS}    6s
    Sleep    0.3s

Click If Exists
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    3s
    Run Keyword If    ${ok}    Click Element    ${locator}
