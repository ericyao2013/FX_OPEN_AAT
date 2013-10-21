/****************************************************
  
  废墟版跟踪天线接收端代码
  Copyright (C) 2013  Coeus Rowe

  连线方式：
                                  |---------Arduino 5V输出-------|
                                  |                              |
                              100k电阻                        4.7k电阻
                                  |                              |
  图传接收机音频-----100nF电容----|----------------三极管9014----|----Arduino D6PIN
                                  |                   |
                              100k电阻                |
                                  |                   |
  图传接收机音频地-------------Arduino GND------------|


  Arduino D2PIN----|------按钮开关----Arduino 5V输出
                10k电阻
                   |
                  GND

  Arduino D13PIN----100欧电阻----LED----GND

  Arduino D5PIN----H舵机信号
  Arduino D9PIN----V舵机信号

  UBEC电源V+ ----- H舵机V+
               |
               --- V舵机V+
               |
               --- Arduino Vin

  UBEC电源V- ----- H舵机V-
               |
               --- V舵机V-
               |
               --- Arduino GND

  注意：只能使用Arduino的6PIN口输入

  @Author 废墟<r.anerg#gmail.com>
  @Link http://anerg.com
  @Date 2013-10-13

****************************************************/

#include <SoftModem.h>
#include "EEPROM.h"
#include "Servo.h"

/***可调选项***/
//这部分参数是辉胜MG996R的参数，你可以根据自己的情况调整
//一定要保证两个舵机的行程刚好是180度，当然可以有些误差
int MIN_PULSE = 550;//舵机0度
int MAX_PULSE = 2160;//舵机180度
//上面两个参数用于控制舵机的总行程
int SERVO_H_OFFSET = -58;//水平舵机中立点偏移量
int SERVO_V_OFFSET = -15;//俯仰舵机中立点偏移量
int SERVO_H_LIMIT = -20;//水平舵机行程补偿
int SERVO_V_LIMIT = 0;//俯仰舵机行程补偿
/**************/



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
  // home_loc.lat = 39904030;
  // home_loc.lng = 116407526;
  // home_loc.alt = 30;
  // current_loc.lat = 39904030;
  // current_loc.lng = 116407526;
  // current_loc.alt = 30;
  // set_home();
  // HOME_READY = 1;
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
    GPS_UPDATE = 0;
  }

}

//按钮被按下产生中断并标识标志位
void btn_press() {
  BUTTON_PRESS = 1;
}