//
//  globle_functions.cpp
//  netsdk_demo
//
//  Created by apple on 15/5/26.
//  Copyright (c) 2015年 wu_pengzhou. All rights reserved.
//

#include "globle_functions.h"

std::string strip_after(const std::string& str, const std::string sep)
{
    // npos + 1 == 0 under 2's complement representation
    // which is also what we want
    return str.substr(str.find_last_of(sep) + 1);
}

std::string strip_n(const std::string& str, size_t num)
{
    const auto size = str.size();
    if (size > num) {
        return str.substr(0, num - 2) + "..";
    }
    else {
        return str + std::string(num - size, ' ');
    }
}

std::string str_now()
{
    time_t t;
    time(&t);
    tm* stTime = localtime(&t);
    
    std::ostringstream oss;
    oss << stTime->tm_year - 1990 << stTime->tm_mon << stTime->tm_mday << stTime->tm_hour << stTime->tm_min << stTime->tm_sec;
    
    return oss.str();
}
