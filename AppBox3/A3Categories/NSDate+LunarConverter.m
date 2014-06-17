//
//  NSDate+LunarConverter.m
//  A3TeamWork
//
//  Created by Byeong Kwon Kwak on 10/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSDate+LunarConverter.h"
#import "A3AppDelegate.h"

@implementation NSDate (LunarConverter)

typedef NSUInteger arrayOfMonths[12];

// 음력 데이터 (평달 - 작은달 :1,  큰달:2 )
// (윤달이 있는 달 - 평달이 작고 윤달도 작으면 :3 , 평달이 작고 윤달이 크면 : 4)
// (윤달이 있는 달 - 평달이 크고 윤달이 작으면 :5,  평달과 윤달이 모두 크면 : 6)
static arrayOfMonths lunarMonthTable_Korean[] = {
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 5, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},   /* 1901 */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 4, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2},   /* 1911 */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 5, 1, 2, 1, 2, 1, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 3, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 5, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},   /* 1921 */
	{2, 1, 2, 2, 3, 2, 1, 1, 2, 1, 2, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2},
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 5, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 5, 1, 2, 1, 1, 2, 2, 1, 2, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},
	{1, 2, 2, 1, 1, 5, 1, 2, 1, 2, 2, 1},
	{2, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1},   /* 1931 */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 6, 1, 2, 1, 2, 1, 1, 2},
	{1, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 4, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},
	{2, 2, 1, 1, 2, 1, 4, 1, 2, 2, 1, 2},
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 1, 2, 2, 4, 1, 1, 2, 1, 2, 1},   /* 1941 */
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},
	{1, 1, 2, 4, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},
	{2, 5, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 3, 2, 1, 2, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},   /* 1951 */
	{1, 2, 1, 2, 4, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 2, 1, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},
	{2, 1, 4, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 5, 2, 1, 2, 2},
	{1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},
	{2, 1, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1},
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},   /* 1961 */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2},
	{1, 2, 5, 2, 1, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 5, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1, 2},   /* 1971 */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1},
	{2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 5, 2, 1, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},
	{2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 6, 1, 2, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},   /* 1981 */
	{2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2, 2},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},
	{2, 1, 2, 2, 1, 1, 2, 1, 1, 5, 2, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 2, 1, 5, 2, 2, 1, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},
	{1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},   /* 1991 */
	{1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},
	{1, 2, 5, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 2, 1, 5, 2, 1, 1, 2},
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 1, 2, 3, 2, 2, 1, 2, 2, 2, 1},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1},
	{2, 2, 2, 3, 2, 1, 1, 2, 1, 2, 1, 2},   /* 2001 */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2},
	{1, 5, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 1},
	{2, 1, 2, 1, 2, 1, 5, 2, 2, 1, 2, 2},
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},
	{2, 2, 1, 1, 5, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 2011 */
	{2, 1, 6, 2, 1, 2, 1, 1, 2, 1, 2, 1},
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},
	{1, 2, 1, 2, 1, 2, 1, 2, 5, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},
	{2, 1, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},
	{2, 1, 2, 5, 2, 1, 1, 2, 1, 2, 1, 2},
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},   /* 2021 */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},
	{1, 5, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},
	{2, 1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2},
	{1, 2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1},
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 1, 2, 2},
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1},
	{2, 1, 5, 2, 1, 2, 2, 1, 2, 1, 2, 1},   /* 2031 */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 5, 2},
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 4, 1, 1, 2, 2, 1, 2},
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1},
	{2, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1, 1},
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1},
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},   /* 2041 */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2}};

// 음력 데이터 (평달 - 작은달 :1,  큰달:2 )
// (윤달이 있는 달 - 평달이 작고 윤달도 작으면 :3 , 평달이 작고 윤달이 크면 : 4)
// (윤달이 있는 달 - 평달이 크고 윤달이 작으면 :5,  평달과 윤달이 모두 크면 : 6)
static arrayOfMonths lunarMonthTable_Chinese[] = {
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},	/* 1899 */
	{1, 2, 1, 1, 2, 1, 2, 5, 2, 2, 1, 2},	/* 1900 */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},   /* 1901 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1902 Verified */
	{1, 2, 1, 2, 3, 2, 1, 1, 2, 2, 1, 2},	/* 1903 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1904 Verified */
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1905 Verified */
	{1, 2, 2, 4, 1, 2, 1, 2, 1, 2, 1, 2},	/* 1906 Verified */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1907 Verified */
	{2, 1, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1908 Verified */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 2, 1, 2},	/* 1909 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2, 1},	/* 1910 Verified */
	{2, 1, 2, 1, 1, 5, 1, 2, 2, 1, 2, 2},   /* 1911 Verified */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1912 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 1913 Verified */
	{2, 2, 1, 2, 4, 1, 2, 1, 1, 2, 1, 2},	/* 1914 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},	/* 1915 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1916 Verified */
	{2, 3, 2, 1, 2, 2, 1, 2, 2, 1, 2, 1},	/* 1917 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1918 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 4, 2, 1, 2, 2, 2},	/* 1919 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1920 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},   /* 1921 Verified */
	{2, 1, 2, 2, 3, 2, 1, 1, 2, 1, 2, 2},	/* 1922 Verified */
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1923 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},	/* 1924 Verified -- Different from Korean */
	{2, 1, 2, 4, 2, 1, 2, 2, 1, 2, 1, 2},	/* 1925 Verified -- Different from Korean */
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1926 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1927 Verified -- Different from Korean */
	{1, 5, 1, 2, 1, 1, 2, 1, 2, 2, 2, 2},	/* 1928 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1929 Verified */
	{1, 2, 2, 1, 1, 5, 1, 2, 1, 2, 2, 1},	/* 1930 Verified */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 1931 Verified -- Different from Korean */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1932 Verified */
	{1, 2, 2, 1, 6, 1, 2, 1, 2, 1, 1, 2},	/* 1933 Verified */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1934 Verified -- Different from Korean */
	{1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1935 Verified */
	{2, 1, 4, 1, 1, 2, 2, 1, 2, 2, 2, 1},	/* 1936 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},	/* 1937 Verified */
	{2, 2, 1, 1, 2, 1, 4, 1, 2, 2, 1, 2},	/* 1938 Verified */
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1939 Verified */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 1940 Verified */
	{2, 2, 1, 2, 2, 4, 1, 1, 2, 1, 2, 1},   /* 1941 Verified */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},	/* 1942 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1943 Verified -- Different from Korean */
	{2, 1, 2, 4, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1944 Verified -- Different from Korean */
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},	/* 1945 Verified */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},	/* 1946 Verified */
	{2, 5, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 1947 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1948 Verified */
	{2, 1, 2, 2, 1, 2, 3, 2, 1, 2, 1, 2},	/* 1949 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1},	/* 1950 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},   /* 1951 Verified */
	{1, 2, 1, 2, 4, 1, 2, 2, 1, 2, 1, 2},	/* 1952 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 2, 1, 2, 2, 1, 2, 1},	/* 1953 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1954 Verified -- Different from Korean */
	{1, 2, 4, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1955 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 1956 Verified */
	{2, 1, 2, 1, 2, 1, 1, 5, 2, 1, 2, 1},	/* 1957 Verified -- Different from Korean */
	{2, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1958 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},	/* 1959 Verified */
	{2, 1, 2, 1, 2, 5, 2, 1, 2, 1, 2, 1},	/* 1960 Verified */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2},   /* 1961 Verified */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1962 Verified */
	{2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1},	/* 1963 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1964 Verified */
	{1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1965 Verified -- Different from Korean */
	{2, 2, 5, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 1966 Verified -- Different from Korean */
	{2, 2, 1, 2, 2, 1, 1, 2, 1, 2, 1, 2},	/* 1967 Verified */
	{1, 2, 1, 2, 2, 1, 5, 2, 1, 2, 1, 2},	/* 1968 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1969 Verified */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},	/* 1970 Verified -- Different from Korean */
	{1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1, 2},   /* 1971 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2},	/* 1972 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1973 Verified -- Different from Korean */
	{2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1, 2},	/* 1974 Verified */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 1975 Verified */
	{2, 2, 1, 2, 1, 2, 1, 5, 1, 2, 1, 2},	/* 1976 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1},	/* 1977 Verified */
	{2, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 1978 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 6, 1, 2, 2, 1, 2, 1},	/* 1979 Verified */
	{2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 1980 Verified */
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2},   /* 1981 Verified */
	{2, 1, 2, 3, 2, 1, 1, 2, 1, 2, 2, 2},	/* 1982 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},	/* 1983 Verified */
	{2, 1, 2, 2, 1, 1, 2, 1, 1, 5, 2, 2},	/* 1984 Verified */
	{1, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1985 Verified */
	{1, 2, 2, 1, 2, 2, 1, 2, 1, 2, 1, 1},	/* 1986 Verified */
	{2, 1, 2, 1, 2, 5, 2, 2, 1, 2, 1, 1},	/* 1987 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1988 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 2, 1, 2, 1, 2, 2, 2},	/* 1989 Verified -- Different from Korean */
	{1, 2, 1, 1, 5, 1, 2, 1, 2, 2, 2, 2},	/* 1990 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2},   /* 1991 Verified */
	{1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2},	/* 1992 Verified */
	{1, 2, 5, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 1993 Verified */
	{2, 2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2},	/* 1994 Verified */
	{1, 2, 2, 1, 2, 1, 2, 5, 1, 2, 1, 2},	/* 1995 Verified -- Different from Korean */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 1},	/* 1996 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 1997 Verified -- Different from Korean */
	{2, 1, 1, 2, 3, 2, 2, 1, 2, 2, 1, 2},	/* 1998 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1},	/* 1999 Verified */
	{2, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1},	/* 2000 Verified */
	{2, 2, 1, 5, 2, 1, 1, 2, 1, 2, 1, 2},   /* 2001 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1},	/* 2002 Verified */
	{2, 2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2},	/* 2003 Verified */
	{1, 5, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2},	/* 2004 Verified */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1},	/* 2005 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 1, 5, 2, 2, 1, 2, 2},	/* 2006 Verified */
	{1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2},	/* 2007 Verified */
	{2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2},	/* 2008 Verified */
	{2, 2, 1, 1, 5, 1, 2, 1, 2, 1, 2, 2},	/* 2009 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2},	/* 2010 Verified */
	{2, 1, 2, 2, 1, 2, 1, 1, 2, 1, 2, 1},   /* 2011 Verified */
	{2, 1, 2, 5, 2, 1, 2, 1, 2, 1, 2, 1},	/* 2012 Verified -- Different from Korean */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},	/* 2013 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 1, 2, 5, 2, 1, 2},	/* 2014 Verified */
	{1, 2, 1, 1, 2, 1, 2, 2, 2, 1, 2, 1},	/* 2015 Verified */
	{2, 1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2},	/* 2016 Verified */
	{1, 2, 1, 2, 1, 4, 1, 2, 1, 2, 2, 2},	/* 2017 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2},	/* 2018 Verified */
	{2, 1, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2},	/* 2019 Verified -- Different from Korean */
	{1, 2, 2, 5, 2, 1, 1, 2, 1, 2, 1, 2},	/* 2020 Verified -- Different from Korean */
	{1, 2, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1},   /* 2021 Verified */
	{2, 1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2},	/* 2022 Verified */
	{1, 5, 1, 2, 2, 1, 2, 2, 1, 2, 1, 2},	/* 2023 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1},	/* 2024 Verified */
	{2, 1, 2, 1, 1, 5, 2, 1, 2, 2, 2, 1},	/* 2025 Verified */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2, 1},	/* 2026 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1},	/* 2027 Verified -- Different from Korean */
	{2, 2, 2, 1, 5, 1, 2, 1, 1, 2, 2, 1},	/* 2028 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 2},	/* 2029 Verified -- Different from Korean */
	{1, 2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 1},	/* 2030 Verified */
	{1, 2, 5, 2, 1, 2, 2, 1, 2, 1, 2, 1},   /* 2031 Verified -- Different from Korean */
	{2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},	/* 2032 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 5, 2},	/* 2033 Verified */
	{1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2},	/* 2034 Verified -- Different from Korean */
	{2, 1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2},	/* 2035 Verified */
	{2, 2, 1, 2, 1, 4, 1, 1, 2, 1, 2, 2},	/* 2036 Verified -- Different from Korean */
	{2, 2, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2},	/* 2037 Verified */
	{2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 1},	/* 2038 Verified */
	{2, 1, 2, 2, 5, 2, 1, 2, 1, 2, 1, 1},	/* 2039 Verified -- Different from Korean */
	{2, 1, 2, 2, 1, 2, 1, 2, 2, 1, 2, 1},	/* 2040 Verified -- Different from Korean */
	{1, 2, 1, 2, 1, 2, 2, 1, 2, 2, 1, 2},   /* 2041 Verified -- Different from Korean */
	{1, 5, 1, 2, 1, 2, 1, 2, 2, 1, 2, 2},	/* 2042 Verified -- Different from Korean */
	{1, 2, 1, 1, 2, 1, 1, 2, 2, 1, 2, 2}};	/* 2043 Verified */

+ (NSDateComponents *)lunarCalcWithComponents:(NSDateComponents *)components gregorianToLunar:(BOOL)isGregorianToLunar leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth
{
	arrayOfMonths *lunarMonthTable = isKorean ? lunarMonthTable_Korean:lunarMonthTable_Chinese;

    NSInteger solYear, solMonth, solDay;
    NSInteger lunYear, lunMonth, lunDay;
    NSInteger lunMonthDay;
	BOOL lunLeapMonth = NO;
    NSInteger lunIndex;
	
    NSInteger solMonthDay[] = {31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	
	NSInteger year = [components year];
	NSInteger month = [components month];
	NSInteger day = [components day];
	
	/* range check */
	if ((year < 1900) || (year > 2043))
	{
		//		alert('1900년부터 2043년까지만 지원합니다');
        if( resultLeapMonth != NULL )
            *resultLeapMonth = lunLeapMonth;
		return nil;
	}
	
	/* 속도 개선을 위해 기준 일자를 여러개로 한다 */
	if (year >= 2000)
	{
		/* 기준일자 양력 2000년 1월 1일 (음력 1999년 11월 25일) */
		solYear = 2000;
		solMonth = 1;
		solDay = 1;
		lunYear = 1999;
		lunMonth = 11;
		lunDay = 25;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 29;	/* 2000 년 2월 28일 */
		lunMonthDay = 30;	/* 1999년 11월 */
	}
	else if (year >= 1970)
	{
		/* 기준일자 양력 1970년 1월 1일 (음력 1969년 11월 24일) */
		solYear = 1970;
		solMonth = 1;
		solDay = 1;
		lunYear = 1969;
		lunMonth = 11;
		lunDay = 24;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 28;	/* 1970 년 2월 28일 */
		lunMonthDay = 30;	/* 1969년 11월 */
	}
	else if (year >= 1940)
	{
		/* 기준일자 양력 1940년 1월 1일 (음력 1939년 11월 22일) */
		solYear = 1940;
		solMonth = 1;
		solDay = 1;
		lunYear = 1939;
		lunMonth = 11;
		lunDay = 22;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 29;	/* 1940 년 2월 28일 */
		lunMonthDay = 29;	/* 1939년 11월 */
	}
	else
	{
		/* 기준일자 양력 1900년 1월 1일 (음력 1899년 12월 1일) */
		solYear = 1900;
		solMonth = 1;
		solDay = 1;
		lunYear = 1899;
		lunMonth = 12;
		lunDay = 1;
		lunLeapMonth = NO;
		
		solMonthDay[1] = 28;	/* 1900 년 2월 28일 */
		lunMonthDay = 30;	/* 1899년 12월 */
	}
	
	lunIndex = lunYear - 1899;
	
	while (true)
	{
		//		document.write(solYear + "-" + solMonth + "-" + solDay + "<->");
		//		document.write(lunYear + "-" + lunMonth + "-" + lunDay + " " + lunLeapMonth + " " + lunMonthDay + "<br>");
		
		if ((isGregorianToLunar) &&
			(year == solYear) &&
			(month == solMonth) &&
			(day == solDay))
		{
			//			return new myDate(lunYear, lunMonth, lunDay, lunLeapMonth);
			NSDateComponents *resultComponents = [[NSDateComponents alloc] init];
			[resultComponents setDay:lunDay];
			[resultComponents setMonth:lunMonth];
			[resultComponents setYear:lunYear];

			resultComponents.weekday = components.weekday;

			if( resultLeapMonth != NULL )
                *resultLeapMonth = lunLeapMonth;
			
			return resultComponents;
		}
		else if (!isGregorianToLunar &&
				 (year == lunYear) &&
				 (month == lunMonth) &&
				 (day == lunDay) &&
				 (isLeapMonth == lunLeapMonth))
		{
			NSDateComponents *resultComponents = [[NSDateComponents alloc] init];
			[resultComponents setDay:solDay];
			[resultComponents setMonth:solMonth];
			[resultComponents setYear:solYear];

			NSDate *date = [[A3AppDelegate instance].calendar dateFromComponents:resultComponents];
			resultComponents = [[A3AppDelegate instance].calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:date];

            if( resultLeapMonth != NULL )
                *resultLeapMonth = lunLeapMonth;
			
			return resultComponents;
		}
		
		/* add a day of solar calendar */
		if ((solMonth == 12) && (solDay == 31))
		{
			solYear++;
			solMonth = 1;
			solDay = 1;
			
			/* set monthDay of Feb */
			if (solYear % 400 == 0)
				solMonthDay[1] = 29;
			else if (solYear % 100 == 0)
				solMonthDay[1] = 28;
			else if (solYear % 4 == 0)
				solMonthDay[1] = 29;
			else
				solMonthDay[1] = 28;
			
		}
		else if (solMonthDay[solMonth - 1] == solDay)
		{
			solMonth++;
			solDay = 1;
		}
		else
			solDay++;
		
		/* add a day of lunar calendar */
		if ((lunMonth == 12) &&
			(((lunarMonthTable[lunIndex][lunMonth - 1] == 1) && (lunDay == 29)) ||
			 ((lunarMonthTable[lunIndex][lunMonth - 1] == 2) && (lunDay == 30))))
		{
			lunYear++;
			lunMonth = 1;
			lunDay = 1;
			
			if (lunYear > 2043) {
				//				alert("입력하신 달은 없습니다.");
				break;
			}
			
			lunIndex = lunYear - 1899;
			
			if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
				lunMonthDay = 30;
		}
		else if (lunDay == lunMonthDay)
		{
			if ((lunarMonthTable[lunIndex][lunMonth - 1] >= 3)
				&& (lunLeapMonth == NO))
			{
				lunDay = 1;
				lunLeapMonth = YES;
			}
			else
			{
				lunMonth++;
				lunDay = 1;
				lunLeapMonth = NO;
			}
			
			if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
				lunMonthDay = 30;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 3)
				lunMonthDay = 29;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
					 (lunLeapMonth == NO))
				lunMonthDay = 29;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
					 (lunLeapMonth == YES))
				lunMonthDay = 30;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
					 (lunLeapMonth == NO))
				lunMonthDay = 30;
			else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
					 (lunLeapMonth == YES))
				lunMonthDay = 29;
			else if (lunarMonthTable[lunIndex][lunMonth - 1] == 6)
				lunMonthDay = 30;
		}
		else
			lunDay++;
	}
    if( resultLeapMonth != NULL )
        *resultLeapMonth = lunLeapMonth;
	return nil;
}

// 음력날짜일 경우 해당일이 윤달인지 확인
+ (BOOL)isLunarLeapMonthAtDateComponents:(NSDateComponents *)dateComponents isKorean:(BOOL)isKorean
{
    arrayOfMonths *lunarMonthTable = isKorean ? lunarMonthTable_Korean:lunarMonthTable_Chinese;

    NSInteger lunIndex;
	
	NSInteger year = [dateComponents year];
	NSInteger month = [dateComponents month];

	/* range check */
	if ((year < 1900) || (year > 2043))
	{
		//		alert('1900년부터 2043년까지만 지원합니다');
		return NO;
	}
    
    lunIndex = year - 1899;
    return (lunarMonthTable[lunIndex][month-1] > 2);
}

+ (NSInteger)lastMonthDayForLunarYear:(NSInteger)year month:(NSInteger)month isKorean:(BOOL)isKorean
{
    arrayOfMonths *lunarMonthTable = isKorean ? lunarMonthTable_Korean:lunarMonthTable_Chinese;
    
    if ((year < 1900) || (year > 2043)){
        return -1;
    }
    NSInteger lunIndex = year - 1899;
    NSInteger lunMonth = month;
    NSInteger lunMonthDay = 29;
    BOOL lunLeapMonth = (lunarMonthTable[lunIndex][month-1] > 2);
    
    if (lunarMonthTable[lunIndex][lunMonth - 1] == 1)
        lunMonthDay = 29;
    else if (lunarMonthTable[lunIndex][lunMonth - 1] == 2)
        lunMonthDay = 30;
    else if (lunarMonthTable[lunIndex][lunMonth - 1] == 3)
        lunMonthDay = 29;
    else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
             (lunLeapMonth == NO))
        lunMonthDay = 29;
    else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 4) &&
             (lunLeapMonth == YES))
        lunMonthDay = 30;
    else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
             (lunLeapMonth == NO))
        lunMonthDay = 30;
    else if ((lunarMonthTable[lunIndex][lunMonth - 1] == 5) &&
             (lunLeapMonth == YES))
        lunMonthDay = 29;
    else if (lunarMonthTable[lunIndex][lunMonth - 1] == 6)
        lunMonthDay = 30;
    
    return lunMonthDay;
}

+ (NSDate *)dateOfLunarFromSolarDate:(NSDate *)date leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth
{
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    dateComp = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:YES leapMonth:isLeapMonth korean:isKorean resultLeapMonth:resultLeapMonth];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
    return result;
}

+ (NSDate *)dateOfSolarFromLunarDate:(NSDate *)date leapMonth:(BOOL)isLeapMonth korean:(BOOL)isKorean resultLeapMonth:(BOOL*)resultLeapMonth
{
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    dateComp = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:NO leapMonth:isLeapMonth korean:isKorean resultLeapMonth:resultLeapMonth];
    NSDate *result = [[NSCalendar currentCalendar] dateFromComponents:dateComp];
    return result;
}

+ (BOOL)isLunarDateComponents:(NSDateComponents *)dateComp isKorean:(BOOL)isKorean
{
    NSInteger lastMonthDay = [self lastMonthDayForLunarYear:dateComp.year month:dateComp.month isKorean:isKorean];
    if (dateComp.day <= lastMonthDay) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isLunarLeapMonthDate:(NSDate *)date isKorean:(BOOL)isKorean
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];

    arrayOfMonths *lunarMonthTable = isKorean ? lunarMonthTable_Korean:lunarMonthTable_Chinese;
    
    NSInteger lunIndex;
	
	NSInteger year = [dateComponents year];
	NSInteger month = [dateComponents month];
    
	/* range check */
	if ((year < 1900) || (year > 2043))
	{
		//		alert('1900년부터 2043년까지만 지원합니다');
		return NO;
	}
    
    lunIndex = year - 1899;
    return (lunarMonthTable[lunIndex][month-1] > 2);
}

@end
