//
//  globle_functions.h
//  netsdk_demo
//
//  Created by apple on 15/5/26.
//  Copyright (c) 2015年 wu_pengzhou. All rights reserved.
//

#ifndef __netsdk_demo__globle_functions__
#define __netsdk_demo__globle_functions__

#include <sstream>
#include <time.h>

std::string strip_after(const std::string& str, const std::string sep);

// str.size() >= 2 && num >= 2
std::string strip_n(const std::string& str, size_t num);

std::string str_now();

#endif /* defined(__netsdk_demo__globle_functions__) */
