#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/select.h>

#include "conn_linux_socket.h"
#include "things.h"

#define TX_BUF_SIZE  1024 * 1024

Linux_socket::Linux_socket() {
    sockfd              = -1;
    _tx_buf             = (char*)malloc(TX_BUF_SIZE);
    _tx_buf_len         = 0;
    
    isUseIPV6 = false;
    
}
Linux_socket::~Linux_socket() {
    if (sockfd != -1) {
        shutdown(sockfd, SHUT_RDWR);
    };
    if (_tx_buf) {
        free(_tx_buf);
        _tx_buf = NULL;
    }
}
int Linux_socket::set_connect_info(const char* connection_str) {
    int result;
    char buf[50];
    if (strlen(connection_str) > sizeof(buf)) { return -1; };
    while (1) {
        strcpy(buf, connection_str);
        char *p, *p1, *p2, *p3, *p4;
        p = get_token_first((char*)&buf, '='); p1 = p;
        p = get_token_next(p, ';');      p2 = p;
        p = get_token_next(p, '=');      p3 = p;
        p = get_token_rest(p);           p4 = p;
        if (strcmp(p1, "host") != 0) { result = -1; break;};
        if (strcmp(p3, "port") != 0) { result = -1; break;};
        _port = atoi(p4);
        strcpy(_host, p2);
        
        result = 0;
        break;
    };
    if (result < 0) {
        _port = 0;
    };
    return result;
};

int Linux_socket::do_connect_to() {
    if (_port == 0) return -1;
    
    //=======================================================
    struct addrinfo *result;
    struct addrinfo *res;
    struct hostent* server;
    int flags;
    int yes = 1;
    
    struct addrinfo addrCriteria;
    memset(&addrCriteria,0,sizeof(addrCriteria));
    addrCriteria.ai_family=AF_UNSPEC;
    addrCriteria.ai_socktype=SOCK_STREAM;
    addrCriteria.ai_protocol=IPPROTO_TCP;


    //判定网络类型    指定特定接口信息
    int error = getaddrinfo(_host, "1100", &addrCriteria, &result);
    if (error == 0)
    {
        struct sockaddr_in *sa;
        for (res = result; res != NULL; res = res->ai_next)
        {
            if (AF_INET6 == res->ai_addr->sa_family)
            {
                isUseIPV6 = true;
                char buf[128] = {};
                sa = (struct sockaddr_in*)res->ai_addr;
                inet_ntop(AF_INET6, &((reinterpret_cast<struct sockaddr_in6*>(sa))->sin6_addr), buf, 128);
                
                sockfd = socket(res->ai_family, res->ai_socktype, 0);
                if (sockfd == -1) {
                    
                    return -5;
                }
                
                
                memset(&sockaddr_ipv6, 0, sizeof(sockaddr_ipv6)); //注意初始化
                
                sockaddr_ipv6.sin6_family = AF_INET6;
                sockaddr_ipv6 = *(struct sockaddr_in6 *) res->ai_addr;
                sockaddr_ipv6.sin6_port = htons(_port);
                int ret = connect(sockfd, (struct sockaddr*) &sockaddr_ipv6, sizeof(sockaddr_ipv6));
                //TODO....遇到IPv6就退出
                if((ret < 0) && (errno != EINPROGRESS)) {
                    printf("connect error\n");
                    return -5;
                }
                break;
            }
            else if (AF_INET == res->ai_addr->sa_family)
            {
                isUseIPV6 = false;
                char buf[32] = {};
                sa = (struct sockaddr_in*)res->ai_addr;
                inet_ntop(AF_INET, &sa->sin_addr, buf, 32);
                
                sockfd = socket(res->ai_family, res->ai_socktype, 0);
                if (sockfd == -1) {
                    return -5;
                }
                
                sockfd = socket(AF_INET, SOCK_STREAM, 0);
                if(sockfd  < 0) { error = -1; break; };
                if(sockfd == 0) { error = -2; break; };
                
                if ((flags = fcntl(sockfd, F_GETFL, 0)) < 0) {
                    error = -3; break;
                }
                
                int x = fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);
                if (x  < 0) { error = -4; break; };
                
                setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
                
                bzero((char *)&sockaddr_ipv4, sizeof(sockaddr_ipv4));
                sockaddr_ipv4.sin_family = AF_INET;
                
                struct hostent* server;
                server = gethostbyname(_host);
                if(server == NULL) { error = -5; break; };
                memcpy(&sockaddr_ipv4.sin_addr.s_addr, server->h_addr, server->h_length);
                //sockaddr_ipv4 = *(struct sockaddr_in *) res->ai_addr;
                sockaddr_ipv4.sin_port = htons(_port);
                int ret = connect(sockfd, (struct sockaddr*)&sockaddr_ipv4, sizeof(sockaddr_ipv4));
                //TODO....
                if((ret < 0) && (errno != EINPROGRESS)) {
                    printf("connect error\n");
                    return -5;
                }
                
                break;

            }
        }
    }
    freeaddrinfo(result);
    //=======================================================
    
    return error;
}
int Linux_socket::do_disconnect() {
    if (sockfd >= 0) {
        shutdown(sockfd, SHUT_RDWR);
        close(sockfd);
        sockfd = -1;
        _tx_buf_len = 0;
    }
    return 0;
}
int Linux_socket::connected(){
    
    ssize_t ret;
    struct timeval tv;
    fd_set rfdset, wfdset;
    if (sockfd != -1) {
        FD_ZERO(&rfdset); FD_SET(sockfd, &rfdset);
        FD_ZERO(&wfdset); FD_SET(sockfd, &wfdset);
        tv.tv_sec = 0;
        tv.tv_usec = 0;
        ret = select(sockfd + 1, &rfdset, &wfdset, NULL, &tv);
        if (ret > 0) {
            if (FD_ISSET(sockfd, &rfdset) || FD_ISSET(sockfd, &wfdset)) {
                if (isUseIPV6 == false) {
                    ret = connect(sockfd,
                                  (const struct sockaddr *) &sockaddr_ipv4,
                                  sizeof(sockaddr_ipv4));
                }
                else {
                    ret = connect(sockfd,
                                  (const struct sockaddr *) &sockaddr_ipv6,
                                  sizeof(sockaddr_ipv6));
                }
                int err = errno;
                if  (err == EISCONN) {  
                    return 1;
                } else {  
                    ret = errno;  
                }
            }
            return 1;
        }
        else if (ret == 0) {
            return 1;
        }
    };
    return 0;
};

ssize_t Linux_socket::do_send_data(const char* buf, size_t len){
    if (sockfd < 0) { return -1; };
    if (TX_BUF_SIZE - _tx_buf_len < len) {
        printf("tx buf full!!! tx_buf_len = %ld  len = %ld",
               _tx_buf_len, len);
        do_disconnect();
        return -1;
    }
    memcpy(&_tx_buf[_tx_buf_len], buf, len);
    _tx_buf_len = _tx_buf_len + len;
    return _tx_buf_len;
}
int Linux_socket::do_send_tx_buf_out()
{
    if (_tx_buf_len == 0) { return 0; };
    ssize_t sent = send(sockfd, _tx_buf, _tx_buf_len, 0);
    if (sent < 0) {
        if (errno == EWOULDBLOCK)  {
            // tc_log(TC_LOG_DEBUG, "[do_send_data] EWOULDBLOCK: %ld", _tx_buf_len);
        } else {
            // tc_log(TC_LOG_DEBUG, "[do_send_data] err = %d", errno);
            do_disconnect();
            return -1;
        }
    } else if (sent == 0) {
        // tc_log(TC_LOG_DEBUG, "[do_send_data] sent = 0  err = %d", errno);
        do_disconnect();
        return -1;
    } else if (sent > 0) {
        if (_tx_buf_len < sent) {
            // tc_log(TC_LOG_INFO,
            //        "[do_send_data] _tx_buf_len(%ld) < sent(%ld)",
            //        _tx_buf_len, sent);
            _tx_buf_len = 0;
        }
        // tc_log(TC_LOG_DETAIL,
        //        "[do_send_data] sent out : %ld / %ld  %ld left",
        //        _tx_buf_len, sent, _tx_buf_len - sent);
        _tx_buf_len = _tx_buf_len - sent;
        if (_tx_buf_len > 0) {
            memmove(&_tx_buf[0], &_tx_buf[sent], _tx_buf_len);
        }
    };
    return sent;
}
ssize_t Linux_socket::do_recv_data(char* buf, size_t len) {
    ssize_t rc;
    struct timeval tv;
    fd_set fdset;
    if (sockfd < 0) { return 0; };
    do_send_tx_buf_out();
    FD_ZERO(&fdset);
    if (sockfd < 0) { return 0; };
    FD_SET(sockfd, &fdset);
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    rc = select(sockfd + 1, &fdset, NULL, NULL, &tv);
    if ((rc > 0) && FD_ISSET(sockfd, &fdset)) {
        rc = recv(sockfd, buf, len, 0);
        len = (int)rc;
        if (rc < 0) {
            if (errno != EWOULDBLOCK) {
                len = -1;
                sockfd = -1;
            }
        } else if (rc == 0) {
            sockfd = -1;
        } else {
            buf[len] = 0;
        };
    } else {
        len = 0;
    };
    return len;
}
