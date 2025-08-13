*** Settings ***
Documentation     ชุดทดสอบสำหรับเพิ่มสินค้าในระบบจัดการสินค้า
Suite Setup       Open Browser To Login Page
Suite Teardown    Close Browser
Test Setup        Login And Go To Product Page
Resource          ../login_tests/resource.robot
Library           random

*** Variables ***
${VALID_USERNAME}    zzz
${VALID_PASSWORD}    zz12zz
${PRODUCT_BASE}     ทดสอบสินค้า
${PRODUCT_PAGE_URL} /product/
${TIMEOUT}          15s

*** Test Cases ***
Add Product (Basic)
    [Documentation]    ทดสอบการเพิ่มสินค้าใหม่ด้วยชื่อที่ไม่ซ้ำและยืนยันการสร้าง
    Maximize Browser Window
    ${random_number}=    Generate Random Number    1000    9999
    ${product_name}=     Set Variable    ${PRODUCT_BASE} ${random_number}
    
    # เพิ่มสินค้าใหม่
    Click Add Product Button
    Input Product Details    ${product_name}
    Save Product
    Verify Product Creation Success    ${product_name}
    Capture Page Screenshot

*** Keywords ***
Login And Go To Product Page
    [Documentation]    ล็อกอินด้วยข้อมูลที่ถูกต้องและไปยังหน้าสินค้า
    Input Username    ${VALID_USERNAME}
    Input Password    ${VALID_PASSWORD}
    Submit Credentials
    Welcome Page Should Be Open
    Sleep    1s
    Capture Page Screenshot
    Navigate To Product Management Page

Navigate To Product Management Page
    [Documentation]    นำทางไปยังหน้าจัดการสินค้าผ่านเมนู
    Wait Until Element Is Visible    xpath=//span[contains(text(), 'สินค้า')]    ${TIMEOUT}
    Click Element                    xpath=//span[contains(text(), 'สินค้า')]
    Capture Page Screenshot          before_all_link.png
    Wait Until Element Is Visible    xpath=//a[@href='/product/' and contains(@class, 'text-gray-600') and contains(., 'ทั้งหมด')]    ${TIMEOUT}
    Scroll Element Into View         xpath=//a[@href='/product/' and contains(@class, 'text-gray-600') and contains(., 'ทั้งหมด')]
    Click Element                    xpath=//a[@href='/product/' and contains(@class, 'text-gray-600') and contains(., 'ทั้งหมด')]
    Wait Until Element Is Visible    xpath=//a[contains(text(), 'จัดการสินค้า')]    ${TIMEOUT}
    Capture Page Screenshot          after_all_link.png
    Click Element                    xpath=//a[contains(text(), 'จัดการสินค้า')]
    Wait Until Page Contains Element xpath=//h2[contains(., 'จัดการสินค้า')]    ${TIMEOUT}
    Capture Page Screenshot

Click Add Product Button
    [Documentation]    คลิกปุ่มลอยเพื่อเพิ่มสินค้าใหม่
    Wait Until Element Is Visible    css=button[data-tip="เพิ่มสินค้า"]    ${TIMEOUT}
    Scroll Element Into View    css=button[data-tip="เพิ่มสินค้า"]
    Click Element    css=button[data-tip="เพิ่มสินค้า"]
    Wait Until Element Is Visible    xpath=//input[@placeholder='ชื่อสินค้า']    ${TIMEOUT}

Input Product Details
    [Arguments]    ${product_name}
    [Documentation]    กรอกรายละเอียดสินค้าใหม่
    Input Text    xpath=//input[@placeholder='ชื่อสินค้า']    ${product_name}
    # ตัวอย่าง: เพิ่มฟิลด์อื่นหากต้องการ
    # Input Text    xpath=//input[@placeholder='บาร์โค้ด']    1234567890
    # Input Text    xpath=//input[@placeholder='ราคา']    100
    # Select From List By Label    xpath=//select[@name='category']    หมวดหมู่ตัวอย่าง

Save Product
    [Documentation]    บันทึกสินค้าและยืนยันการกระทำ
    Click Element    xpath=//button[contains(text(), 'บันทึกข้อมูล')]
    Wait Until Element Is Visible    xpath=//div[contains(@class, 'swal2-success')]    ${TIMEOUT}
    Click Element    css=button.swal2-confirm

Verify Product Creation Success
    [Arguments]    ${product_name}
    [Documentation]    ยืนยันว่าสินค้าถูกสร้างสำเร็จ
    Wait Until Page Contains Element    xpath=//td[contains(text(), '${product_name}')]    ${TIMEOUT}
    Capture Page Screenshot

Generate Random Number
    [Arguments]    ${min}    ${max}
    [Documentation]    สร้างตัวเลขสุ่มระหว่าง min และ max
    ${random}=    Evaluate    random.randint(${min}, ${max})    modules=random
    RETURN    ${random}