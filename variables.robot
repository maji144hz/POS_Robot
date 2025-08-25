*** Settings ***
Documentation     Shared variables for all test suites

*** Variables ***
${BASE_URL}                            http://localhost:5173
${BROWSER}                             chrome
${TIMEOUT}                             20s
${SCREEN_DIR}                          screenshots

# Credentials
${VALID USER}                          admin1
${VALID PASSWORD}                      12345678

# Inventory / Products
${PRODUCT_LIST_URL}                    ${BASE_URL}/product
${BTN_ADD_PRODUCT}                     id=stock-add-product-button
${CREATE_URL}                          ${BASE_URL}/products/create-product

# Upload Image (คลิกพื้นที่อัปโหลดก่อน เพื่อให้โผล่ input[type=file])
${UPLOAD_CLICK_AREA}                   xpath=//*[contains(@class,'flex') and contains(@class,'flex-col') and contains(.,'เพิ่มรูปภาพ')] | //div[.//span[contains(normalize-space(.),'เพิ่มรูปภาพ')]]
${INPUT_FILE_OPT1}                     xpath=//input[@type='file' and (contains(@id,'image') or contains(@name,'image') or contains(@accept,'image'))]
${INPUT_FILE_OPT2}                     xpath=//input[@type='file']
${PRODUCT_IMAGE_PATH}                  E:${/}มหาลัย${/}โปรเจค${/}Robot_Pos${/}photo${/}น้ำยาล้างจาน.jpg

# Form fields
${INPUT_NAME}                          id=create-product-name-input
${INPUT_DESC}                          id=create-product-description-input
${SELECT_CATEGORY}                     id=create-product-category-select
${CATEGORY_VALUE}                      6855a82ec16f3c50f07fc142    # ของใช้ในบ้าน

${INPUT_BARCODE_PACK}                  id=barcodePack
${INPUT_BARCODE_UNIT}                  id=barcodeUnit
${INPUT_PACK_SIZE}                     id=packSize
${INPUT_PRICE_UNIT}                    id=create-product-sellingpriceperunit-input
${INPUT_PRICE_PACK}                    id=create-product-sellingpriceperpack-input

# Initial lot (by name)
${INPUT_INIT_QTY}                      xpath=//input[@name='initialLot.quantity']
${INPUT_INIT_PURCHASE}                 xpath=//input[@name='initialLot.purchasePrice']
${INPUT_INIT_EXPDATE}                  xpath=//input[@name='initialLot.expirationDate']
${EXPDATE_VALUE}                       2025-09-11   # YYYY-MM-DD (ตรงกับ 11/09/2025)

# Save button (หลาย fallback)
${BTN_SAVE_OPT1}                       id=create-product-submit-button
${BTN_SAVE_OPT2}                       xpath=//button[normalize-space()='บันทึกข้อมูล' or normalize-space()='บันทึก']
${BTN_SAVE_OPT3}                       css=button.btn-success, button.bg-green-500

# Loading / Dialog
${SPINNERS}                            css=.ant-spin,.loading,.v-overlay--active,.swal2-container
${SWAL_CONFIRM}                        css=button.swal2-confirm


