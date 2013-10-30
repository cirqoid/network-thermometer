/*
 * arm_test.cpp
 *
 *  Created on: May 14, 2012
 *      Author: simon
 */


#include "ch.h"
#include "hal.h"

#include "lwipthread.h"
#include "web.h"
#include "dhcp.h"

#include "ds18b20.h"

#include <lwip/ip_addr.h>

WORKING_AREA(wa_ds18b20_polling, 512);

volatile float currentTemp;
volatile float lastReadings[12];

msg_t ds18b20_polling_thread(void *p)
{
    chThdSleep(1000);
    DS18B20_Init();

    int seconds = 0;
    systime_t time = chTimeNow();
    while (true)
    {
        time += MS2ST(1000);

        currentTemp = DS18B20_GetTemp(0);

        if (!(++seconds % 3600))
        {
            for (int i = 11; i > 0; i--)
                lastReadings[i] = lastReadings[i - 1];

            lastReadings[0] = currentTemp;
        }

        chThdSleepUntil(time);
    }
}

int main()
{
    halInit();
    chSysInit();

    // Now set up the LWIP thread
    struct ip_addr netmask;
    struct ip_addr address;
    struct ip_addr gateway;
    IP4_ADDR(&address, 0, 0, 0, 0);
    IP4_ADDR(&netmask, 255, 255, 255,  0);
    IP4_ADDR(&gateway, 192, 168,   0,  1);

    static uint8_t macaddrarray[6] = {0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};
    struct lwipthread_opts ip_opts;
    ip_opts.macaddress = macaddrarray;
    ip_opts.netmask    = netmask.addr;
    ip_opts.gateway    = gateway.addr;
    ip_opts.address    = address.addr;

    //Creates the LWIP threads (it changes priority internally).
    chThdCreateStatic(wa_lwip_thread, LWIP_THREAD_STACK_SIZE, NORMALPRIO + 2, lwip_thread, &ip_opts);

    //Creates the HTTP thread (it changes priority internally).
    chThdCreateStatic(wa_http_server, sizeof(wa_http_server), NORMALPRIO + 1,http_server, NULL);

    //Creates the DHCP thread.
    chThdCreateStatic(wa_dhcp_client, sizeof(wa_dhcp_client), DHCP_THREAD_PRIORITY, dhcp_client, NULL);

    //Creates the DS18B20 polling thread.
    chThdCreateStatic(wa_ds18b20_polling, sizeof(wa_ds18b20_polling), LOWPRIO, ds18b20_polling_thread, NULL);

    while(1)
    {
        chThdSleep(200);
    }

}

