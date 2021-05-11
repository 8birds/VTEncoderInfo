/*
 MIT License

 Copyright (c) 2019 8 Birds Video Inc

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <CoreMedia/CoreMedia.h>

static void printCFString(CFStringRef val){
    static const int VAL_BUF_LEN = 1024;
    char valBuf[VAL_BUF_LEN];

    Boolean haveStr = CFStringGetCString(val,
                                         valBuf,
                                         VAL_BUF_LEN,
                                         kCFStringEncodingUTF8);
    if(!haveStr){
        fprintf(stderr, "WARNING: failed to get string\n");
        valBuf[0] = 0;
    }

    printf("%s", valBuf);
}

static void printCFNumber(CFNumberRef val){
    char buf[32];

    CFNumberType numType = CFNumberGetType(val);
    CFNumberGetValue(val, numType, (void*)buf);

    switch(numType){
        case kCFNumberSInt8Type:
        case kCFNumberCharType:
            printf("%hhd", *(SInt8*)buf);
            break;

        case kCFNumberSInt16Type:
        case kCFNumberShortType:
            printf("%hd", *(SInt16*)buf);
            break;

        case kCFNumberSInt32Type:
        case kCFNumberIntType:
            printf("%d", *(SInt32*)buf);
            break;

        case kCFNumberSInt64Type:
        case kCFNumberLongLongType:
            printf("%lld", *(SInt64*)buf);
            break;

        case kCFNumberFloat32Type:
        case kCFNumberFloatType:
            printf("%f", *(float*)buf);
            break;

        case kCFNumberFloat64Type:
        case kCFNumberCGFloatType:
        case kCFNumberDoubleType:
            printf("%f", *(double*)buf);
            break;

        case kCFNumberLongType:
            printf("%ld", *(long*)buf);
            break;

        case kCFNumberCFIndexType:
            printf("%lld", (UInt64)*(CFIndex*)buf);
            break;

        case kCFNumberNSIntegerType:
            printf("%lld", (UInt64)*(NSInteger*)buf);
            break;

        default:
            printf("?");
    }
}

static void printStringProperty(const char* name,
                                CFStringRef val,
                                int pad)
{
    static const int VAL_BUF_LEN = 1024;
    char valBuf[VAL_BUF_LEN];

    Boolean haveStr = CFStringGetCString(val,
                                         valBuf,
                                         VAL_BUF_LEN,
                                         kCFStringEncodingUTF8);
    if(!haveStr){
        fprintf(stderr, "WARNING: failed to get string\n");
        valBuf[0] = 0;
    }

    valBuf[VAL_BUF_LEN - 1] = 0;
    printf("%*s%s: ", pad, " ", name);
    printCFString(val);
    printf("\n");
}

static void printCFType(CFTypeRef ref){
    CFTypeID typeID = CFGetTypeID(ref);
    if(typeID == CFStringGetTypeID())
        printCFString(ref);
    else if(typeID == CFNumberGetTypeID())
        printCFNumber(ref);
    else
        printf("<Unknown type ID %lu>", typeID);
}

static const char* codecTypeName(CMVideoCodecType codecType){
    switch(codecType){
        case kCMVideoCodecType_Animation: return "Apple Animation";
        case kCMVideoCodecType_Cinepak: return "Cinepak";
        case kCMVideoCodecType_JPEG: return "JPEG";
        case kCMVideoCodecType_JPEG_OpenDML: return "JPEG with OpenDML extensions";
        case kCMVideoCodecType_SorensonVideo: return "Sorenson Video";
        case kCMVideoCodecType_SorensonVideo3: return "Sorenson 3 Video";
        case kCMVideoCodecType_H263: return "H.263";
        case kCMVideoCodecType_H264: return "AVC/H.264";
        case kCMVideoCodecType_HEVC: return "HEVC/H.265";
        case kCMVideoCodecType_HEVCWithAlpha: return "HEVC/H.265 Alpha";
        case kCMVideoCodecType_DolbyVisionHEVC: return "Dolby Vision HEVC/H.265";
        case kCMVideoCodecType_MPEG4Video: return "MPEG4 Video";
        case kCMVideoCodecType_MPEG2Video: return "MPEG2 Video";
        case kCMVideoCodecType_MPEG1Video: return "MPEG Video";
        case kCMVideoCodecType_VP9: return "VP9";
        case kCMVideoCodecType_DVCNTSC: return "DV NTSC";
        case kCMVideoCodecType_DVCPAL: return "DV PAL";
        case kCMVideoCodecType_DVCProPAL: return "DVCPro PAL";
        case kCMVideoCodecType_DVCPro50NTSC: return "DVCPro-50 NTSC";
        case kCMVideoCodecType_DVCPro50PAL: return "DVCPro-50 PAL";
        case kCMVideoCodecType_DVCPROHD720p60: return "DVCPro-HD 720p60";
        case kCMVideoCodecType_DVCPROHD720p50: return "DVCPro-HD 720p50";
        case kCMVideoCodecType_DVCPROHD1080i60: return "DVCPro-HD 1080i60";
        case kCMVideoCodecType_DVCPROHD1080i50: return "DVCPro-HD 1080i50";
        case kCMVideoCodecType_DVCPROHD1080p30: return "DVCPro-HD 1080p30";
        case kCMVideoCodecType_DVCPROHD1080p25: return "DVCPro-HD 1080p25";
        case kCMVideoCodecType_AppleProRes4444XQ: return "ProRes 4444 XQ";
        case kCMVideoCodecType_AppleProRes4444: return "ProRes 4444";
        case kCMVideoCodecType_AppleProRes422HQ: return "ProRes 422 HQ";
        case kCMVideoCodecType_AppleProRes422: return "ProRes 422";
        case kCMVideoCodecType_AppleProRes422LT: return "ProRes 422 LT";
        case kCMVideoCodecType_AppleProRes422Proxy: return "ProRes 422 Proxy";
        case kCMVideoCodecType_AppleProResRAW: return "ProRes RAW";
        case kCMVideoCodecType_AppleProResRAWHQ: return "ProRes RAW HQ";

        case kCMPixelFormat_32ARGB: return "8-bit ARGB";
        case kCMPixelFormat_32BGRA: return "8-bit BGRA";
        case kCMPixelFormat_24RGB: return "8-bit RGB";
        case kCMPixelFormat_16BE555: return "5-bit RGB Big Endian";
        case kCMPixelFormat_16BE565: return "5-6-5 RGB Big Endian";
        case kCMPixelFormat_16LE555: return "5-bit RGB Little Endian";
        case kCMPixelFormat_16LE565: return "5-6-5 RGB Little Endian";
        case kCMPixelFormat_16LE5551: return "5-bit chroma 1-bit alpha RGB Little Endian";
        case kCMPixelFormat_422YpCbCr8: return "8-bit CbY'CrY' 4:2:2";
        case kCMPixelFormat_422YpCbCr8_yuvs: return "8-bit Y'CbY'Cr";
        case kCMPixelFormat_444YpCbCr8: return "8-bit Y'CbCr 4:4:4";
        case kCMPixelFormat_4444YpCbCrA8: return "8-bit Y'CbCrA 4:4:4:4";
        case kCMPixelFormat_422YpCbCr16: return "10 to 16-bit Y'CbCr 4:2:2";
        case kCMPixelFormat_422YpCbCr10: return "10-bit Y'CbCr 4:2:2";
        case kCMPixelFormat_444YpCbCr10: return "10-bit Y'CbCr 4:4:4";
        case kCMPixelFormat_8IndexedGray_WhiteIsZero: return "Indexed Gray-scale";

        default: return "<UNKNOWN>";
    }
}

static void printCodecTypeProperty(const char* name,
                                   CMVideoCodecType codecType,
                                   int pad)
{
    printf("%*s%s: %s\n", pad, " ", name, codecTypeName(codecType));
}

static void printSupportedProperty(CFDictionaryRef propInfo,
                                   CFStringRef key,
                                   int pad)
{
    printf("%*s", pad, " ");
    printCFString(key);
    printf("\n");

    CFStringRef rwStatus = CFDictionaryGetValue(propInfo,
                                                kVTPropertyReadWriteStatusKey);

    if(rwStatus){
        if(CFStringCompare(rwStatus,
                           kVTPropertyReadWriteStatus_ReadOnly,
                           0) == kCFCompareEqualTo)
        {
            printf("%*sValue is read-only.\n", pad + 4, " ");
        } else {
            printf("%*sValue is read-write.\n", pad + 4, " ");
        }
    }

    CFNumberRef minValue = CFDictionaryGetValue(propInfo,
                                                kVTPropertySupportedValueMinimumKey);

    if(minValue != NULL){
        printf("%*sMinimum value: ", pad + 4, " ");
        printCFNumber(minValue);
        printf("\n");
    }

    CFNumberRef maxValue = CFDictionaryGetValue(propInfo,
                                                kVTPropertySupportedValueMaximumKey);

    if(maxValue != NULL){
        printf("%*sMaximum value: ", pad + 4, " ");
        printCFNumber(maxValue);
        printf("\n");
    }

    CFArrayRef listOfValues = CFDictionaryGetValue(propInfo,
                                                   kVTPropertySupportedValueListKey);

    if(listOfValues){
        CFIndex len = CFArrayGetCount(listOfValues);
        for(CFIndex i = 0; i < len ; i++){
            CFTypeRef val = CFArrayGetValueAtIndex(listOfValues, i);
            printf("%*s", pad + 4, " ");
            printCFType(val);
            printf("\n");
        }
    }
}

static void printEncoderSupportedProperties(CFStringRef encoderID,
                                            CMVideoCodecType codecType,
                                            int pad)
{
    CFMutableDictionaryRef encSpec;
    encSpec = CFDictionaryCreateMutable(NULL,
                                        1,
                                        &kCFTypeDictionaryKeyCallBacks,
                                        &kCFTypeDictionaryValueCallBacks);

    if(encSpec == NULL){
        fprintf(stderr, "Out of memory.\n");
        exit(ENOMEM);
    }

    CFDictionaryAddValue(encSpec, kVTVideoEncoderList_EncoderID, encoderID);

    CFDictionaryRef supportedProps = NULL;
    OSStatus status = VTCopySupportedPropertyDictionaryForEncoder(1920,
                                                                  1080,
                                                                  codecType,
                                                                  encSpec,
                                                                  NULL,
                                                                  &supportedProps);

    CFRelease(encSpec);

    if(status != 0 || supportedProps == NULL){
        fprintf(stderr,
                "Failed to get supported properties for encoder: %d\n",
                (int)status);
        return;
    }

    Boolean printedFirstProp = false;
    CFIndex count = CFDictionaryGetCount(supportedProps);
    CFStringRef* keys = calloc(count, sizeof(CFStringRef));
    CFTypeRef* values = calloc(count, sizeof(CFTypeRef));

    if(keys == NULL || values == NULL){
        fprintf(stderr, "Out of memory.\n");
        exit(ENOMEM);
    }

    CFDictionaryGetKeysAndValues(supportedProps,
                                 (const void**)keys,
                                 (const void**)values);

    for(CFIndex i = 0; i < count; i++){
        CFDictionaryRef propInfo = CFDictionaryGetValue(supportedProps,
                                                        keys[i]);

        if(!printedFirstProp){
            printf("%*sSupported Properties:\n", pad, " ");
            printedFirstProp = true;
        }

        printSupportedProperty(propInfo, keys[i], pad + 4);
    }

    free((void*)keys);
    free((void*)values);

    CFRelease(supportedProps);
}

static void printEncoderProperties(CFDictionaryRef encInfo){
    CFStringRef displayName = CFDictionaryGetValue(encInfo, kVTVideoEncoderList_DisplayName);
    CFNumberRef codecTypeNum = CFDictionaryGetValue(encInfo, kVTVideoEncoderList_CodecType);
    CFStringRef encoderID = CFDictionaryGetValue(encInfo, kVTVideoEncoderList_EncoderID);
    CFStringRef codecName = CFDictionaryGetValue(encInfo, kVTVideoEncoderList_CodecName);
    CFStringRef encoderName = CFDictionaryGetValue(encInfo, kVTVideoEncoderList_EncoderName);

    CMVideoCodecType codecType;
    Boolean gotNum = CFNumberGetValue(codecTypeNum,
                                      kCFNumberSInt32Type,
                                      &codecType);

    if(!gotNum){
        fprintf(stderr, "WARNING: failed to get codec type value\n");

        codecType = -1;
    }

    printStringProperty("Encoder", displayName, 0);
    printCodecTypeProperty("Codec Type", codecType, 4);
    printStringProperty("Encoder ID", encoderID, 4);
    printStringProperty("Codec Name", codecName, 4);
    printStringProperty("Encoder Name", encoderName, 4);

    printEncoderSupportedProperties(encoderID, codecType, 4);

    printf("\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CFArrayRef encoders = NULL;
        OSStatus status = VTCopyVideoEncoderList(NULL, &encoders);
        if(status != 0 || encoders == NULL){
            fprintf(stderr, "Could not get encoder list: %d\n", status);
            return 1;
        }

        int encoderCount = (int)CFArrayGetCount(encoders);
        for(int i = 0; i < encoderCount; i++){
            CFDictionaryRef encInfo = CFArrayGetValueAtIndex(encoders, i);
            printEncoderProperties(encInfo);
        }

        CFRelease(encoders);
    }

    return 0;
}
