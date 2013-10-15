/****************************************************
  
  废墟版跟踪天线发射端代码
  Copyright (C) 2013  Coeus Rowe

  连线方式：
   GNG----1.8K欧电阻----|----0.22uF电容--|--8.2K欧电阻----3PIN
    |                   |                |
    |                   |              1.8k电阻
    |                   |                |
  图传地           图传音频线           GND
                                        

  注意：只能使用Arduino的3PIN数字口输出

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-11

****************************************************/


#include "SoftModem.h"

SoftModem modem;

/* 定义坐标数据结构 */
struct Location {
    long lat;//纬度
    long lng;//经度
    long alt;//高度
};
//当前坐标
struct Location current_loc = {0, 0, 0};
//GPS数据是否有新的
static int GPS_UPDATE = 0;
//要发送的字符串
String MSG;

void setup() {
  Serial.begin(38400);
  Serial.println("!!FX AAT is Ready!!");
  delay(3000);
  modem.begin();
}

void loop() {
 //  get_gps();
	// if(GPS_UPDATE == 1) {
	// 	send_gps();
	// }
  send_test();
  delay(2000);
}

