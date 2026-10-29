/**
 * 这是模型的静态常量配置
 * 和货架的配置（支持从数据库加载）
 * @author 谢宁, Created on 2020-01-07
 * @modified 新增 loadShelfListFromAPI 方法，支持从库房库位数据动态生成3D场景
 */
/** ***************************************************************** */

var PLANE_LENGTH = 24;  //货架板面长度
var PLANE_WIDTH = 55;   //货架板面宽度
var PLANE_HEIGHT = 2;   //货架板面高度
var HOLDER_LENGTH = 2;  //支架长度
var HOLDER_WIDTH = 2;   //支架宽度
var HOLDER_HEIGHT = 25; //支架高度
var LAYER_NUM = 3;      //货架层数
var COLUMN_NUM = 2;     //货架每层列数
var BOX_SIZE = 16;      //货物的大小(立方体)

//货架数组
var shelf_list = new Array();
//库区数组
var zone_list = new Array();
//货物数据映射：shelfId -> array of cargo data
var cargo_data_map = {};

//默认演示数据
function loadDefaultData() {
    shelf_list.splice(0, shelf_list.length);
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A1',shelfName:'货架A1',x:-100,y:27,z:0});
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A2',shelfName:'货架A2',x:0,y:27,z:0});
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A3',shelfName:'货架A3',x:100,y:27,z:0});
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A4',shelfName:'货架A4',x:200,y:27,z:0});
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A5',shelfName:'货架A5',x:300,y:27,z:0});
    shelf_list.push({StorageZoneId:'Z1',shelfId:'A6',shelfName:'货架A6',x:400,y:27,z:0});

    zone_list.splice(0, zone_list.length);
    zone_list.push({zoneId:'Z1', zoneName:'库区1号', x:0, z:0, width:1000, length:500, color:'FF0000', fontSize:20, position:'左对齐'});

    cargo_data_map = {};
}

/**
 * 从API返回的3D数据动态构建货架列表、库区列表和货物数据
 * @param {Object} apiData - 从 /digital/simulation/location-data 接口返回的数据
 */
function loadShelfListFromAPI(apiData) {
    if (!apiData || !apiData.data) {
        loadDefaultData();
        return;
    }
    var data = apiData.data;
    var shelves = data.shelves || [];
    var zones = data.zones || [];
    var warehouses = data.warehouses || [];

    shelf_list.splice(0, shelf_list.length);
    zone_list.splice(0, zone_list.length);
    cargo_data_map = {};

    // 如果没有数据，使用默认演示数据
    if (shelves.length === 0 && zones.length === 0) {
        loadDefaultData();
        return;
    }

    // 1. 为每个库房创建一个库区
    var warehouseZones = {};
    var zoneIndex = 0;
    var zoneStartX = -500;
    var zoneSpacing = 600;

    for (var i = 0; i < warehouses.length; i++) {
        var wh = warehouses[i];
        var zoneId = 'Z' + (i + 1);
        warehouseZones[wh.id] = {
            zoneId: zoneId,
            zoneName: wh.warehouseCode + '-' + wh.warehouseName,
            baseX: zoneStartX + i * zoneSpacing,
            baseZ: 0,
            wh: wh
        };
        zone_list.push({
            zoneId: zoneId,
            zoneName: wh.warehouseName || wh.warehouseCode,
            x: zoneStartX + i * zoneSpacing + 250,
            z: 0,
            width: 500,
            length: 400,
            color: '3398DB',
            fontSize: 20,
            position: '居中'
        });
    }

    // 如果没有库房但有库位，创建一个默认库区
    if (warehouses.length === 0 && shelves.length > 0) {
        warehouseZones['default'] = {
            zoneId: 'Z1',
            zoneName: '默认库区',
            baseX: 0,
            baseZ: 0
        };
        zone_list.push({
            zoneId: 'Z1',
            zoneName: '默认库区',
            x: 0,
            z: 0,
            width: 600,
            length: 400,
            color: 'FF0000',
            fontSize: 20,
            position: '居中'
        });
    }

    // 2. 为每个库位生成一个货架
    var shelfIndex = 1;
    var shelfXSpacing = 70;
    var shelfZSpacing = 0;

    // 统计每个库区的库位数
    var zoneShelfCount = {};
    for (var j = 0; j < shelves.length; j++) {
        var loc = shelves[j];
        var whId = loc.warehouseId || 'default';
        if (!zoneShelfCount[whId]) {
            zoneShelfCount[whId] = 0;
        }
        zoneShelfCount[whId]++;
    }

    // 逐库区放置货架
    var zoneShelfIndex = {};
    for (var j = 0; j < shelves.length; j++) {
        var loc = shelves[j];
        var whId = loc.warehouseId || 'default';
        var zoneInfo = warehouseZones[whId];
        if (!zoneInfo) {
            zoneInfo = warehouseZones['default'] || {zoneId:'Z0', baseX: -200, baseZ: 0};
        }

        if (!zoneShelfIndex[whId]) {
            zoneShelfIndex[whId] = 0;
        }
        var idxInZone = zoneShelfIndex[whId];
        var countInZone = zoneShelfCount[whId] || 1;

        // 计算货架位置：在库区范围内均匀分布
        var zoneWidth = 400; // 库区可用宽度
        var startX = zoneInfo.baseX + 50;
        var spacing = countInZone > 1 ? (zoneWidth - 100) / (countInZone - 1) : 0;
        var posX = startX + idxInZone * spacing;
        var posZ = zoneInfo.baseZ;

        var shelfId = 'S' + (shelfIndex++);
        var shelfName = loc.locationName || loc.locationCode || shelfId;

        shelf_list.push({
            StorageZoneId: zoneInfo.zoneId,
            shelfId: shelfId,
            shelfName: shelfName,
            x: posX,
            y: 27,
            z: posZ,
            // 扩展属性，用于展示详情
            locationCode: loc.locationCode,
            locationId: loc.locationId,
            warehouseName: loc.warehouseName,
            warehouseType: loc.warehouseType,
            capacity: loc.capacity
        });

        // 存储该货位上的货物数据
        if (loc.cargos && loc.cargos.length > 0) {
            cargo_data_map[shelfId] = loc.cargos;
        }

        zoneShelfIndex[whId]++;
    }

    // 处理没有库位的独立库区
    for (var i = 0; i < zones.length; i++) {
        var z = zones[i];
        var zoneId = 'Z_EXTRA_' + (i + 1);
        var baseX = zoneStartX + (warehouses.length + i) * zoneSpacing;
        zone_list.push({
            zoneId: zoneId,
            zoneName: z.warehouseName || z.warehouseCode,
            x: baseX + 250,
            z: 0,
            width: 500,
            length: 300,
            color: '1C86EE',
            fontSize: 18,
            position: '居中'
        });
    }
}

// 获取货物数据的函数
function getCargoDataByShelfId(shelfId) {
    if (cargo_data_map && cargo_data_map[shelfId]) {
        return cargo_data_map[shelfId];
    }
    return [];
}

function GET_PLANE_LENGTH(){
  return PLANE_LENGTH;
}

function GET_PLANE_WIDTH(){
  return PLANE_WIDTH;
}

function GET_PLANE_HEIGHT(){
  return PLANE_HEIGHT;
}

function GET_HOLDER_LENGTH(){
  return HOLDER_LENGTH;
}

function GET_HOLDER_WIDTH(){
  return HOLDER_WIDTH;
}

function GET_HOLDER_HEIGHT(){
  return HOLDER_HEIGHT;
}

function GET_LAYER_NUM(){
  return LAYER_NUM;
}

function GET_COLUMN_NUM(){
  return COLUMN_NUM;
}

function GET_BOX_SIZE(){
  return BOX_SIZE;
}

function GET_SHELF_LIST(){
  return shelf_list;
}

function GET_ZONE_LIST(){
  return zone_list;
}
