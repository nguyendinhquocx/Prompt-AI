
## Tốt lắm, để tôi mô tả bối cảnh:

### Tôi đang sử dụng google sheet để nhập dữ liệu và import vào trong supabase tạo dashboard từ các trường dữ liệu,  đây là code lấy dữ liệu từ các file con và gộp vào file tổng (google sheet), do các sheet con chưa có id nên khi gộp vào file tổng này nó sẽ sinh mã id cho mỗi hàng để là duy nhất rồi mới load vào supabase :

"
function  onOpen() {

var  ui = SpreadsheetApp.getUi();

ui.createMenu('Import')

.addItem('Cập nhật', 'syncData')

.addItem('Cập nhật + ID', 'syncDataWithId')

.addToUi();

}

  

function  get_thong_tin_data() {

return  read(SpreadsheetApp.getActiveSpreadsheet().getId(), "Cấu hình!A3:S")

.filter(e => e[0] === "Actived")

.map(e => ({

idSheetGet: e[1], rgGet: e[2], idSheetRe: e[3], rgRe: e[4],

colGet: e[5], includeHeader: e[6] === "Actived",

colFil4: e[7], cd4: e[8], colFil5: e[9], cd5: e[10],

colfil1: e[11], cd1a: e[12], cd1b: e[13],

colNumber: e[14], fromNumber: e[15], toNumber: e[16],

colNull: e[17], nullCondition: e[18]

}));

}

  

function  syncData() {

const  startTime = new  Date();

const  grData = {};

get_thong_tin_data().forEach(config => {

const  data = read(config.idSheetGet, config.rgGet);

const  columnsToGet = config.colGet?.trim() || getColumnsFromRange(config.rgGet);

const  processRow = row => columnsToGet ?

columnsToGet.split(",").map(i => row[i] || "") : row;

  

const  checkConditions = (row, index) => {

if (index === 0) return  config.includeHeader;

// Điều kiện ngày

const  dateCheck = !config.colfil1 || (() => {

// Dữ liệu gốc đã ở định dạng mm/dd/yyyy, không cần reverse

const  rowDate = row[config.colfil1] && new  Date(row[config.colfil1]);

// Chỉ reverse ngày cấu hình từ dd/mm/yyyy sang mm/dd/yyyy

const  startDate = config.cd1a && new  Date(config.cd1a.split('/').reverse().join('/'));

const  endDate = config.cd1b && new  Date(config.cd1b.split('/').reverse().join('/'));

return (!startDate || rowDate >= startDate) && (!endDate || rowDate <= endDate);

})();

  

// Điều kiện nhiều cột

const  multiCheck = (() => {

if (config.colFil4 && config.cd4 && config.colFil5 && config.cd5) {

return  checkFilterCondition(row[config.colFil4], config.cd4) ||

checkFilterCondition(row[config.colFil5], config.cd5);

}

return !(config.colFil4 && config.cd4) || checkFilterCondition(row[config.colFil4], config.cd4);

})();

  

// Điều kiện number

const  numCheck = !config.colNumber || (() => {

const  val = parseFloat(row[config.colNumber]);

return !isNaN(val) &&

(!config.fromNumber || val >= parseFloat(config.fromNumber)) &&

(!config.toNumber || val <= parseFloat(config.toNumber));

})();

  

// Điều kiện null - hỗ trợ nhiều cột phân tách bằng dấu phẩy

const  nullCheck = !config.colNull || !config.nullCondition || (() => {

const  columns = config.colNull.toString().split(',').map(col => col.trim());

return  columns.every(col => checkFilterCondition(row[col], config.nullCondition));

})();

  

return  dateCheck && multiCheck && numCheck && nullCheck;

};

  

const  filteredRows = data

.map((row, index) => checkConditions(row, index) ? processRow(row) : null)

.filter(Boolean);

  

if (filteredRows.length) {

const  key = `${config.idSheetRe}-${config.rgRe}`;

grData[key] = grData[key] || { info: [{ range: config.rgRe, values: [] }], idFile: config.idSheetRe };

grData[key].info[0].values.push(...filteredRows);

}

});

  

Object.values(grData).forEach(({ info, idFile }) => {

const  result = update(info[0], idFile);

try {

const [, col, row] = info[0].range.match(/^(.*?[A-Z])(\d+)$/);

const  sheet = SpreadsheetApp.openById(idFile).getSheetByName(info[0].range.split('!')[0]);

const  maxRows = sheet.getMaxRows();

const  startRow = parseInt(row) + result.totalUpdatedRows;

if (startRow <= maxRows) {

clear(idFile, [`${col}${startRow}:ZZ`]);

}

} catch (error) {

console.log("Clear skipped");

}

});

const  endTime = new  Date();

const  ss = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Cấu hình");

const  currentTime = Utilities.formatDate(endTime, Session.getScriptTimeZone(), "dd/MM-HH:mm");

ss.getRange("E1").setValue(currentTime);

ss.getRange("F1").setValue((endTime - startTime)/1000 + "s");

return  "success";

}

  

function  getColumnsFromRange(range) {

const [, start, end] = range.match(/([A-Z]+)\d+:([A-Z]+)/) || [];

if (!start) return  null;

const  toNum = col => [...col].reduce((acc, char) =>

acc * 26 + char.charCodeAt(0) - 64, 0) - 1;

return  Array.from(

{ length: toNum(end) - toNum(start) + 1 },

(_, i) => toNum(start) + i

).join(',');

}

  

function  checkFilterCondition(value, pattern) {

if (!pattern?.trim()) return  true;

const  val = value?.toString().trim() ?? "";

// Xử lý các điều kiện null/not null

if (pattern === 'null') return !val;

if (pattern === 'not null') return !!val;

// Xử lý điều kiện NOT với <>

if (pattern.startsWith('<>')) {

const  actualPattern = pattern.slice(2); // Bỏ đi "<>" ở đầu

return  val !== actualPattern; // So sánh khác giá trị

}

// Xử lý điều kiện OR (nhiều điều kiện)

if (pattern.includes('🔸'))

return  pattern.split('🔸').some(p => checkFilterCondition(val, p));

// Xử lý wildcard

pattern = pattern.trim();

return  pattern.startsWith('*') && pattern.endsWith('*') ? val.includes(pattern.slice(1, -1)) :

pattern.startsWith('*') ? val.endsWith(pattern.slice(1)) :

pattern.endsWith('*') ? val.startsWith(pattern.slice(0, -1)) :

val === pattern;

}

  

function  read(spreadsheetId, range) {

return  Sheets.Spreadsheets.Values.get(spreadsheetId, range).values;

}

  

function  update(data, spreadsheetId) {

return  Sheets.Spreadsheets.Values.batchUpdate({

valueInputOption: "USER_ENTERED",

data: data

}, spreadsheetId);

}

  

function  clear(spreadsheetId, ranges) {

const [sheetName, range] = ranges[0].split('!');

const  startRow = parseInt(range.split(':')[0].match(/\d+/)[0]);

const  sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName(sheetName);

const  lastRow = sheet.getMaxRows();

sheet.getRange(startRow, 1, 1, sheet.getLastColumn()).clearContent();

const  remainingRows = lastRow - (startRow + 1) + 1;

if (remainingRows > 0) {

sheet.deleteRows(startRow + 1, remainingRows);

}

}

  

function  syncDataWithId() {

const  startTime = new  Date();

const  grData = {};

get_thong_tin_data().forEach(config => {

const  data = read(config.idSheetGet, config.rgGet);

const  columnsToGet = config.colGet?.trim() || getColumnsFromRange(config.rgGet);

const  processRow = (row, index) => {

const  processedRow = columnsToGet ?

columnsToGet.split(",").map(i => row[i] || "") : row;

// Thêm ID duy nhất vào cuối mỗi row (trừ header)

if (index > 0 || !config.includeHeader) {

const  uniqueId = generateUniqueId();

processedRow.push(uniqueId);

} else  if (config.includeHeader && index === 0) {

// Thêm header cho cột ID

processedRow.push("ID");

}

return  processedRow;

};

  

const  checkConditions = (row, index) => {

if (index === 0) return  config.includeHeader;

// Điều kiện ngày

const  dateCheck = !config.colfil1 || (() => {

const  rowDate = row[config.colfil1] && new  Date(row[config.colfil1]);

const  startDate = config.cd1a && new  Date(config.cd1a.split('/').reverse().join('/'));

const  endDate = config.cd1b && new  Date(config.cd1b.split('/').reverse().join('/'));

return (!startDate || rowDate >= startDate) && (!endDate || rowDate <= endDate);

})();

  

// Điều kiện nhiều cột

const  multiCheck = (() => {

if (config.colFil4 && config.cd4 && config.colFil5 && config.cd5) {

return  checkFilterCondition(row[config.colFil4], config.cd4) ||

checkFilterCondition(row[config.colFil5], config.cd5);

}

return !(config.colFil4 && config.cd4) || checkFilterCondition(row[config.colFil4], config.cd4);

})();

  

// Điều kiện number

const  numCheck = !config.colNumber || (() => {

const  val = parseFloat(row[config.colNumber]);

return !isNaN(val) &&

(!config.fromNumber || val >= parseFloat(config.fromNumber)) &&

(!config.toNumber || val <= parseFloat(config.toNumber));

})();

  

// Điều kiện null

const  nullCheck = !config.colNull || !config.nullCondition || (() => {

const  columns = config.colNull.toString().split(',').map(col => col.trim());

return  columns.every(col => checkFilterCondition(row[col], config.nullCondition));

})();

  

return  dateCheck && multiCheck && numCheck && nullCheck;

};

  

const  filteredRows = data

.map((row, index) => checkConditions(row, index) ? processRow(row, index) : null)

.filter(Boolean);

  

if (filteredRows.length) {

const  key = `${config.idSheetRe}-${config.rgRe}`;

grData[key] = grData[key] || { info: [{ range: config.rgRe, values: [] }], idFile: config.idSheetRe };

grData[key].info[0].values.push(...filteredRows);

}

});

  

Object.values(grData).forEach(({ info, idFile }) => {

const  result = update(info[0], idFile);

try {

const [, col, row] = info[0].range.match(/^(.*?[A-Z])(\d+)$/);

const  sheet = SpreadsheetApp.openById(idFile).getSheetByName(info[0].range.split('!')[0]);

const  maxRows = sheet.getMaxRows();

const  startRow = parseInt(row) + result.totalUpdatedRows;

if (startRow <= maxRows) {

clear(idFile, [`${col}${startRow}:ZZ`]);

}

} catch (error) {

console.log("Clear skipped");

}

});

const  endTime = new  Date();

const  ss = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Cấu hình");

const  currentTime = Utilities.formatDate(endTime, Session.getScriptTimeZone(), "dd/MM-HH:mm");

ss.getRange("E1").setValue(currentTime);

ss.getRange("F1").setValue((endTime - startTime)/1000 + "s");

return  "success";

}

  

// Global counter để đảm bảo tuyệt đối không trùng lặp

let  globalIdCounter = 0;

  

function  generateUniqueId() {

// Tăng counter toàn cục để đảm bảo tuyệt đối không trùng

globalIdCounter++;

const  now = new  Date();

// Timestamp với độ chính xác cao

const  timestamp = now.getTime(); // Millisecond từ 1970

// Tạo các thành phần duy nhất

const  counter = globalIdCounter.toString(36).padStart(3, '0'); // Counter base36

const  randomPart = Math.floor(Math.random() * 46656).toString(36).padStart(3, '0'); // 36^3 = 46656

const  timePart = (timestamp % 1679616).toString(36).padStart(4, '0'); // 36^4 = 1679616

// Kết hợp: TimePart(4) + Counter(3) + Random(3) = 10 ký tự

const  uniqueId = `${timePart}${counter}${randomPart}`.toUpperCase();

return  uniqueId;

}

  

function  replaceTrigger() {

const  currentTriggers = ScriptApp.getProjectTriggers();

const  existingTrigger = currentTriggers.filter(trigger => trigger.getHandlerFunction() === "syncData")[0]

if (existingTrigger) ScriptApp.deleteTrigger(existingTrigger)

ScriptApp.newTrigger("syncData")

.timeBased()

.everyHours(1)

// .everyMinutes(15)

// .everyDays(2)

.create()

.getUniqueId()

}
"

### Đây là 1 vài hàng dữ liệu mẫu đã được tôi chuyển qua Json cho bạn dễ hình dung
[
  {
    "so nguoi kham": 30,
    "ngay bat dau kham": "5/5/2025",
    "ngay ket thuc kham": "5/13/2025",
    "ten nhan vien": "Bùi Thị Như Quỳnh",
    "ten cong ty": "CÔNG TY TNHH GREAT AUTO",
    "trang thai kham": "Đã khám xong",
    "gold": "",
    "ngay lay mau": "",
    "cac ngay kham thuc te": "",
    "tong so ngay kham thuc te": "",
    "trung binh ngay": "",
    "trung binh ngay sang": "",
    "trung binh ngay chieu": "",
    "sieu am bung sang": "",
    "sieu am vu sang": "",
    "sieu am giap sang": "",
    "sieu am tim sang": "",
    "sieu am dong mach canh sang": "",
    "sieu am dan hoi mo gan sang": "",
    "sieu am dau do am dao sang": "",
    "x quang sang": "",
    "dien tam do sang": "",
    "kham phu khoa sang": "",
    "do loang xuong sang": "",
    "sieu am bung chieu": "",
    "sieu am vu chieu": "",
    "sieu am giap chieu": "",
    "sieu am tim chieu": "",
    "sieu am dong mach canh chieu": "",
    "sieu am dan hoi mo gan chieu": "",
    "sieu am dau do am dao chieu": "",
    "x quang chieu": "",
    "dien tam do chieu": "",
    "kham phu khoa chieu": "",
    "do loang xuong chieu": "",
    "ID": "ER9C0019TC"
  },
  {
    "so nguoi kham": 8,
    "ngay bat dau kham": "5/6/2025",
    "ngay ket thuc kham": "5/6/2025",
    "ten nhan vien": "Bùi Thị Như Quỳnh",
    "ten cong ty": "VĂN PHÒNG ĐẠI DIỆN HEARTYCHEM CORPORATION TẠI TP HỒ CHÍ MINH",
    "trang thai kham": "Đã khám xong",
    "gold": "",
    "ngay lay mau": "",
    "cac ngay kham thuc te": "",
    "tong so ngay kham thuc te": "",
    "trung binh ngay": "",
    "trung binh ngay sang": "",
    "trung binh ngay chieu": "",
    "sieu am bung sang": "",
    "sieu am vu sang": "",
    "sieu am giap sang": "",
    "sieu am tim sang": "",
    "sieu am dong mach canh sang": "",
    "sieu am dan hoi mo gan sang": "",
    "sieu am dau do am dao sang": "",
    "x quang sang": "",
    "dien tam do sang": "",
    "kham phu khoa sang": "",
    "do loang xuong sang": "",
    "sieu am bung chieu": "",
    "sieu am vu chieu": "",
    "sieu am giap chieu": "",
    "sieu am tim chieu": "",
    "sieu am dong mach canh chieu": "",
    "sieu am dan hoi mo gan chieu": "",
    "sieu am dau do am dao chieu": "",
    "x quang chieu": "",
    "dien tam do chieu": "",
    "kham phu khoa chieu": "",
    "do loang xuong chieu": "",
    "ID": "ER9E002GUG"
  }
]
-> Đây là dữ liệu khám sức khoẻ, do đó khi tôi xây dashboard thì có nhiều bộ phận cùng thực hiện, chẳng hạn nhân sự để thuê bác sĩ, bộ phận khám sức khoẻ để chuẩn bị lực lượng, phòng. Nhân viên sales và quản lí kinh doanh 
### Dashboard với dữ liệu này tôi đã xây xong và chạy hoàn thiện, nhưng giờ là vấn đề mới phát sinh (không liên quan đến dashboard lắm)
1. Bên đơn vị khám sức khoẻ khi xem dashboard muốn biết những công ty nào nằm trong khoảng thời gian thứ 6 hàng tuần + 14 ngày thì sẽ cần gửi mail thông báo cho họ biết để cần chuẩn bị người. Tức là mốc chốt công ty và số người khám là sáng thứ sáu hàng tuần, như hiện tại chẳng hạn nhân viên của tôi điền công ty vào và khoảng thời gian khám nó nằm trong 14 ngày kế tiếp tính theo mốc thứ sáu thì bên khám sức khoẻ họ thấy dashboard số lượng tăng thêm nhưng không biết công ty nào, bao nhiêu người và số lượng đã chốt giờ tăng thêm lại không đáp ứng đủ. Giờ tôi cần biết công ty nào những file con (những nhân viên mà tôi quản lí) nhập vào trong thời gian khám để trong khoảng thứ sáu tuần này đến t5 tuần sau nếu lịch khám nó nằm trong khoảng đó thì cuối ngày sẽ thông báo cho bên khám sức khoẻ họ chuẩn bị. Bạn hiểu vấn đề tôi đang gặp phải không
