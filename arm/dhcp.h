#ifndef _DHCP_H_
#define _DHCP_H_

#ifndef DHCP_THREAD_STACK_SIZE
#define DHCP_THREAD_STACK_SIZE   1024
#endif

#ifndef DHCP_THREAD_PRIORITY
#define DHCP_THREAD_PRIORITY     (LOWPRIO + 1)
#endif

extern WORKING_AREA(wa_dhcp_client, DHCP_THREAD_STACK_SIZE);

#ifdef __cplusplus
extern "C" {
#endif
  msg_t dhcp_client(void *p);
#ifdef __cplusplus
}
#endif

#endif /* _WEB_H_ */

/** @} */
