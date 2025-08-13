*** Settings ***
Suite Setup       Open Browser To Login Page
Suite Teardown    Close Browser
Test Setup        Login And Go To Category Page
Resource          ../login_tests/resource.robot
Library           random

*** Variables ***
${VALID_USERNAME}    1
${VALID_PASSWORD}    123
${CATEGORY_BASE}     ทดสอบหมวดหมู่
${INITIAL_NAME}  หมวดหมู่ที่หนึ่ง  # ชื่อหมวดหมู่เริ่มต้นสำหรับเพิ่มและทดสอบชื่อซ้ำ
${EDITED_NAME}   หมวดหมู่แก้ไขแล้ว  # ชื่อใหม่สำหรับแก้ไข
${ADD_BUTTON_TEXT}        เพิ่มหมวดหมู่
${SAVE_BUTTON_TEXT}       บันทึกสินค้า
${CANCEL_BUTTON_TEXT}     ยกเลิก
${Delete}                 ลบ
${EXPIRATION_DAYS}        1  # จำนวนวันที่จะเพิ่มจากวันปัจจุบัน
${IMAGE_PATH}             E:\\มหาลัย\\โปรเจค\\ke\\robotfarmework\\selenium-screenshot-135.png


*** Test Cases ***
Add Edit Delete Category (All-in-One Robust)
    Maximize Browser Window



   

*** Keywords ***
Login And Go To Category Page
    Input Username    ${VALID_USERNAME}
    Input Password    ${VALID_PASSWORD}
    Submit Credentials
    Welcome Page Should Be Open
    Sleep    1s
    Capture Page Screenshot
    Go To profile Page

Go To profile Page
    Wait Until Page Contains Element    xpath=//span[contains(text(), 'สินค้า')]    5s
    Click Element                       xpath=//span[contains(text(), 'สินค้า')]
    Capture Page Screenshot
    Wait Until Page Contains Element    css=a.p-2.text-gray-600[href='/product/']    10s
    Click Element                       css=a.p-2.text-gray-600[href='/product/']
    Capture Page Screenshot
      Go To Add Product Page

Go To Add Product Page
    # อ้างอิงวิธีใช้ contains(@class, ...) จากตัวอย่าง
    Wait Until Page Contains Element    xpath=//button[contains(@class, 'fixed') and contains(@class, 'text-green-500') and contains(@class, 'rounded-full')]    10s
    Click Element                       xpath=//button[contains(@class, 'fixed') and contains(@class, 'text-green-500') and contains(@class, 'rounded-full')]
    Capture Page Screenshot

    Input Text    xpath=//input[@placeholder="* ชื่อสินค้า"]    ${INITIAL_NAME}
    Input Text    xpath=//textarea[@placeholder="รายละเอียดสินค้า"]    ${INITIAL_NAME}
    Wait Until Element Is Visible    name=categoryId    10s
    Select From List By Value    name=categoryId    685aca6085a1c2f3fd51ec1f
    Input Text    xpath=//input[@placeholder="* จำนวนสินค้า ( ชิ้น/แพ็ค )"]    10
    Input Text    xpath=//input[@placeholder="* บาร์โค้ดแพ็ค"]    10
    Input Text    xpath=//input[@placeholder="* บาร์โค้ดชิ้น"]    10
    Input Text    xpath=//input[@placeholder="* จำนวนสินค้า"]    10
    Input Text    xpath=//input[@placeholder="* ราคาซื้อ"]    10
    Input Text    xpath=//input[@placeholder="* ราคาขายต่อชิ้น"]    10
    Input Text    xpath=//input[@placeholder="* ราคาขายต่อแพ็ค"]    10
    Input Expiration Date

Input Expiration Date
    [Documentation]    กรอกหรือเปลี่ยนวันที่หมดอายุแบบไดนามิก
    ${current_date}=    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d')    modules=datetime
    ${expiration_date}=    Evaluate    (datetime.datetime.strptime('${current_date}', '%Y-%m-%d') + datetime.timedelta(days=${EXPIRATION_DAYS})).strftime('%Y-%m-%d')    modules=datetime
    Wait Until Element Is Visible    name=expirationDate    10s
    Input Text    name=expirationDate    ${expiration_date}
    Capture Page Screenshot
    Upload Product Image

Upload Product Image
    [Documentation]    อัปโหลดรูปภาพสินค้าโดยคลิก label
    ${image_path}=    Set Variable    ${IMAGE_PATH}  # ใช้ตัวแปรจาก Variables
    Wait Until Element Is Visible    xpath=//label[@for="productImage"]    10s
    Click Element    xpath=//label[@for="productImage"]
    Choose File    id=productImage    ${image_path}
    Capture Page Screenshot

    Wait Until Page Contains Element    xpath=//button[contains(text(), '${SAVE_BUTTON_TEXT}')]    10s
    Click Element                       xpath=//button[contains(text(), '${SAVE_BUTTON_TEXT}')]
    Capture Page Screenshot
    Wait Until Page Contains Element    css=button.swal2-confirm    10s
    Click Element 
    