#include "ch.h"

#include "lwip/opt.h"
#include "lwip/arch.h"
#include "lwip/api.h"
#include "lwip/netif.h"
#include "lwip/dhcp.h"

#include "dhcp.h"

#if LWIP_DHCP

/* Private typedef -----------------------------------------------------------*/
typedef enum
{
  DHCP_START=0,
  DHCP_WAIT_ADDRESS,
  DHCP_ADDRESS_ASSIGNED,
  DHCP_TIMEOUT
}
DHCP_State_TypeDef;

/* Private define ------------------------------------------------------------*/
#define MAX_DHCP_TRIES 5

/**
 * Stack area for the dhcp thread.
 */
WORKING_AREA(wa_dhcp_client, DHCP_THREAD_STACK_SIZE);

/**
 * DHCP client thread.
 */
msg_t dhcp_client(void *p) {
    uint32_t IPaddress;
    uint8_t DHCP_state;
    DHCP_state = DHCP_START;

    chThdSleep(2000);

    struct netif *currentNetif = netif_find("ms0");

    while (currentNetif == NULL)
    {
        currentNetif = netif_find("ms0");
    }

    for (;;)
    {
        switch (DHCP_state)
        {
            case DHCP_START:
            {
                dhcp_start(currentNetif);
                IPaddress = 0;
                DHCP_state = DHCP_WAIT_ADDRESS;
            }
            break;

            case DHCP_WAIT_ADDRESS:
            {
                /* Read the new IP address */
                IPaddress = currentNetif->ip_addr.addr;

                if (IPaddress!=0)
                {
                    DHCP_state = DHCP_ADDRESS_ASSIGNED;

                    /* Stop DHCP */
                    dhcp_stop(currentNetif);

                    /* end of DHCP process: LED1 stays ON*/
                    chThdExit(0);
                }
                else
                {
                    /* DHCP timeout */
                    if (currentNetif->dhcp->tries > MAX_DHCP_TRIES)
                    {
                        DHCP_state = DHCP_TIMEOUT;

                        /* Stop DHCP */
                        dhcp_stop(currentNetif);

                        /* end of DHCP process */
                        chThdExit(0);
                    }
                }
            }
            break;

            default: break;
        }
        /* wait 250 ms */
        chThdSleep(250);
    }
}

#endif /* LWIP_DHCP */

/** @} */
