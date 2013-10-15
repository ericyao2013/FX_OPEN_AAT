/****************************************************
  
  废墟版跟踪天线接收端代码
  Copyright (C) 2013  Coeus Rowe

  连线方式：
                             Arduino 5V输出
                                   |
                                100k电阻
                                   |
  图传接收机音频-----0.22uF电容----|----------------|--------Arduino 6PIN
                                   |                |
                                100k电阻        47pF电容
                                   |                |
  图传接收机音频地--------------Arduino GND---------|       

  注意：只能使用Arduino的6PIN口输入

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-13

****************************************************/

#include <SoftModem.h>
#include "EEPROM.h"
#include "Servo.h"


int BUTTON_IRT = 0;//按钮中断，使用外部0，即需要接D2口
int BUTTON_PIN = 2;
int LED_PIN = 13;//LED灯的输出口

Servo SERVO_H;//水平舵机，对应飞机方向
Servo SERVO_V;//俯仰舵机，对应飞机高度

int BUTTON_PRESS = 0;//按钮是否按下
int LED_STAT = 1;


SoftModem modem;

/* 定义坐标数据结构 */
struct Location {
    long lat;//纬度
    long lng;//经度
    long alt;//高度
};
//飞机当前坐标
struct Location current_loc = {0, 0, 0};
//家的坐标
struct Location home_loc = {0, 0, 0};
//GPS数据是否有新的
int GPS_UPDATE = 0;
int HOME_READY = 0;

void setup()
{
  Serial.begin(38400);
  Serial.println("!!FX AAT RX is Ready!!");
  attachInterrupt(BUTTON_IRT, btn_press, RISING);
  pinMode(BUTTON_PIN, INPUT);
  pinMode(LED_PIN, OUTPUT);
  SERVO_H.attach(5);
  SERVO_V.attach(9);
  delay(500);
  init_servo();
  modem.begin();
  get_home();
  delay(1000);
}

void loop()
{

  // test_servo();

  if(BUTTON_PRESS == 1) {
    //连续按住3秒设置家
    for(int i=0; i<30; i++) {
      if(digitalRead(BUTTON_PIN)==LOW) {
        BUTTON_PRESS = 0;
        break;
      }
      //设置阶段,LED闪烁
      if(LED_STAT == 1) {
        digitalWrite(LED_PIN, LOW);
      }
      else {
        digitalWrite(LED_PIN, HIGH);
      }
      LED_STAT = !LED_STAT;
      delay(100);
    }

    if(BUTTON_PRESS == 1) {
      set_home();
      BUTTON_PRESS = 0;
    }

    get_home();
    delay(1000);
  }
  
  get_gps();
  if(HOME_READY == 1 && GPS_UPDATE == 1) {
    move_servo();
  }

}

//按钮被按下产生中断并标识标志位
void btn_press() {
  BUTTON_PRESS = 1;
}