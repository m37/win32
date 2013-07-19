#if __GLASGOW_HASKELL__ >= 701
{-# LANGUAGE Trustworthy #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Module      :  System.Win32.Mem
-- Copyright   :  (c) Alastair Reid, 1997-2003
-- License     :  BSD-style (see the file libraries/base/LICENSE)
--
-- Maintainer  :  Esa Ilari Vuokko <ei@vuokko.info>
-- Stability   :  provisional
-- Portability :  portable
--
-- A collection of FFI declarations for interfacing with Win32.
--
-----------------------------------------------------------------------------

module System.Win32.Mem where

import System.Win32.Types

import Foreign
import Foreign.C.Types

##include "windows_cconv.h"

#include <windows.h>

copyMemory :: Ptr a -> Ptr a -> SIZE_T -> IO ()
copyMemory dest src nbytes = copyBytes dest src (fromIntegral nbytes)

moveMemory :: Ptr a -> Ptr a -> SIZE_T -> IO ()
moveMemory dest src nbytes = moveBytes dest src (fromIntegral nbytes)

fillMemory :: Ptr a -> SIZE_T -> BYTE -> IO ()
fillMemory dest nbytes val =
  memset dest (fromIntegral val) (fromIntegral nbytes)

zeroMemory :: Ptr a -> SIZE_T -> IO ()
zeroMemory dest nbytes = memset dest 0 (fromIntegral nbytes)

foreign import ccall unsafe "string.h" memset :: Ptr a -> CInt -> CSize -> IO ()

foreign import WINDOWS_CCONV unsafe "windows.h GetProcessHeap"
  getProcessHeap :: IO HANDLE

#ifndef __WINE_WINDOWS_H
foreign import WINDOWS_CCONV unsafe "windows.h GetProcessHeaps"
  getProcessHeaps :: DWORD -> Addr -> IO DWORD
#endif

type   HGLOBAL   = HANDLE

type GlobalAllocFlags = UINT

gMEM_INVALID_HANDLE :: GlobalAllocFlags
gMEM_INVALID_HANDLE = #{const GMEM_INVALID_HANDLE}

#{enum GlobalAllocFlags,
 , gMEM_FIXED           = GMEM_FIXED
 , gMEM_MOVEABLE        = GMEM_MOVEABLE
 , gPTR                 = GPTR
 , gHND                 = GHND
 , gMEM_DDESHARE        = GMEM_DDESHARE
 , gMEM_SHARE           = GMEM_SHARE
 , gMEM_LOWER           = GMEM_LOWER
 , gMEM_NOCOMPACT       = GMEM_NOCOMPACT
 , gMEM_NODISCARD       = GMEM_NODISCARD
 , gMEM_NOT_BANKED      = GMEM_NOT_BANKED
 , gMEM_NOTIFY          = GMEM_NOTIFY
 , gMEM_ZEROINIT        = GMEM_ZEROINIT
 }

globalAlloc :: GlobalAllocFlags -> SIZE_T -> IO HGLOBAL
globalAlloc flags size =
  failIfNull "GlobalAlloc" $ c_GlobalAlloc flags size
foreign import WINDOWS_CCONV unsafe "windows.h GlobalAlloc"
  c_GlobalAlloc :: GlobalAllocFlags -> SIZE_T -> IO HGLOBAL

-- %fun GlobalDiscard :: HGLOBAL -> IO HGLOBAL
-- %fail {res1==NULL}{ErrorWin("GlobalDiscard")}

globalFlags :: HGLOBAL -> IO GlobalAllocFlags
globalFlags mem =
  failIf (== gMEM_INVALID_HANDLE) "GlobalFlags" $ c_GlobalFlags mem
foreign import WINDOWS_CCONV unsafe "windows.h GlobalFlags"
  c_GlobalFlags :: HGLOBAL -> IO GlobalAllocFlags

globalFree :: HGLOBAL -> IO HGLOBAL
globalFree mem =
  failIfNull "GlobalFree" $ c_GlobalFree mem
foreign import WINDOWS_CCONV unsafe "windows.h GlobalFree"
  c_GlobalFree :: HGLOBAL -> IO HGLOBAL

globalHandle :: Addr -> IO HGLOBAL
globalHandle addr =
  failIfNull "GlobalHandle" $ c_GlobalHandle addr
foreign import WINDOWS_CCONV unsafe "windows.h GlobalHandle"
  c_GlobalHandle :: Addr -> IO HGLOBAL

globalLock :: HGLOBAL -> IO Addr
globalLock mem =
  failIfNull "GlobalLock" $ c_GlobalLock mem
foreign import WINDOWS_CCONV unsafe "windows.h GlobalLock"
  c_GlobalLock :: HGLOBAL -> IO Addr

-- %fun GlobalMemoryStatus :: IO MEMORYSTATUS

globalReAlloc :: HGLOBAL -> SIZE_T -> GlobalAllocFlags -> IO HGLOBAL
globalReAlloc mem size flags =
  failIfNull "GlobalReAlloc" $ c_GlobalReAlloc mem size flags
foreign import WINDOWS_CCONV unsafe "windows.h GlobalReAlloc"
  c_GlobalReAlloc :: HGLOBAL -> SIZE_T -> GlobalAllocFlags -> IO HGLOBAL

globalSize :: HGLOBAL -> IO SIZE_T
globalSize mem =
  failIfZero "GlobalSize" $ c_GlobalSize mem
foreign import WINDOWS_CCONV unsafe "windows.h GlobalSize"
  c_GlobalSize :: HGLOBAL -> IO SIZE_T

globalUnlock :: HGLOBAL -> IO ()
globalUnlock mem =
  failIfFalse_ "GlobalUnlock" $ c_GlobalUnlock mem
foreign import WINDOWS_CCONV unsafe "windows.h GlobalUnlock"
  c_GlobalUnlock :: HGLOBAL -> IO BOOL

type HeapAllocFlags = DWORD

#{enum HeapAllocFlags,
 , hEAP_GENERATE_EXCEPTIONS	= HEAP_GENERATE_EXCEPTIONS
 , hEAP_NO_SERIALIZE		= HEAP_NO_SERIALIZE
 , hEAP_ZERO_MEMORY		= HEAP_ZERO_MEMORY
 }

heapAlloc :: HANDLE -> HeapAllocFlags -> SIZE_T -> IO Addr
heapAlloc heap flags size =
  failIfNull "HeapAlloc" $ c_HeapAlloc heap flags size
foreign import WINDOWS_CCONV unsafe "windows.h HeapAlloc"
  c_HeapAlloc :: HANDLE -> HeapAllocFlags -> SIZE_T -> IO Addr

heapCompact :: HANDLE -> HeapAllocFlags -> IO SIZE_T
heapCompact heap flags =
  failIfZero "HeapCompact" $ c_HeapCompact heap flags
foreign import WINDOWS_CCONV unsafe "windows.h HeapCompact"
  c_HeapCompact :: HANDLE -> HeapAllocFlags -> IO SIZE_T

heapCreate :: HeapAllocFlags -> SIZE_T -> SIZE_T -> IO HANDLE
heapCreate flags initSize maxSize =
  failIfNull "HeapCreate" $ c_HeapCreate flags initSize maxSize
foreign import WINDOWS_CCONV unsafe "windows.h HeapCreate"
  c_HeapCreate :: HeapAllocFlags -> SIZE_T -> SIZE_T -> IO HANDLE

heapDestroy :: HANDLE -> IO ()
heapDestroy heap =
  failIfFalse_ "HeapDestroy" $ c_HeapDestroy heap
foreign import WINDOWS_CCONV unsafe "windows.h HeapDestroy"
  c_HeapDestroy :: HANDLE -> IO BOOL

heapFree :: HANDLE -> HeapAllocFlags -> Addr -> IO ()
heapFree heap flags addr =
  failIfFalse_ "HeapFree" $ c_HeapFree heap flags addr
foreign import WINDOWS_CCONV unsafe "windows.h HeapFree"
  c_HeapFree :: HANDLE -> HeapAllocFlags -> Addr -> IO BOOL

heapLock :: HANDLE -> IO ()
heapLock heap =
  failIfFalse_ "HeapLock" $ c_HeapLock heap
foreign import WINDOWS_CCONV unsafe "windows.h HeapLock"
  c_HeapLock :: HANDLE -> IO BOOL

heapReAlloc :: HANDLE -> HeapAllocFlags -> Addr -> SIZE_T -> IO Addr
heapReAlloc heap flags addr size =
  failIfNull "HeapReAlloc" $ c_HeapReAlloc heap flags addr size
foreign import WINDOWS_CCONV unsafe "windows.h HeapReAlloc"
  c_HeapReAlloc :: HANDLE -> HeapAllocFlags -> Addr -> SIZE_T -> IO Addr

heapSize :: HANDLE -> HeapAllocFlags -> Addr -> IO SIZE_T
heapSize heap flags addr =
  failIfZero "HeapSize" $ c_HeapSize heap flags addr
foreign import WINDOWS_CCONV unsafe "windows.h HeapSize"
  c_HeapSize :: HANDLE -> HeapAllocFlags -> Addr -> IO SIZE_T

heapUnlock :: HANDLE -> IO ()
heapUnlock heap =
  failIfFalse_ "HeapUnlock" $ c_HeapUnlock heap
foreign import WINDOWS_CCONV unsafe "windows.h HeapUnlock"
  c_HeapUnlock :: HANDLE -> IO BOOL

foreign import WINDOWS_CCONV unsafe "windows.h HeapValidate"
  heapValidate :: HANDLE -> HeapAllocFlags -> Addr -> IO BOOL

type VirtualAllocFlags = DWORD

#{enum VirtualAllocFlags,
 , mEM_COMMIT   = MEM_COMMIT
 , mEM_RESERVE  = MEM_RESERVE
 }

-- % , MEM_TOP_DOWN (not in mingw-20001111 winnt.h)

type ProtectFlags = DWORD

#{enum ProtectFlags,
 , pAGE_READONLY        = PAGE_READONLY
 , pAGE_READWRITE       = PAGE_READWRITE
 , pAGE_EXECUTE         = PAGE_EXECUTE
 , pAGE_EXECUTE_READ    = PAGE_EXECUTE_READ
 , pAGE_EXECUTE_READWRITE = PAGE_EXECUTE_READWRITE
 , pAGE_GUARD           = PAGE_GUARD
 , pAGE_NOACCESS        = PAGE_NOACCESS
 , pAGE_NOCACHE         = PAGE_NOCACHE
 }

type FreeFlags = DWORD

#{enum FreeFlags,
 , mEM_DECOMMIT = MEM_DECOMMIT
 , mEM_RELEASE  = MEM_RELEASE
 }

virtualAlloc :: Addr -> SIZE_T -> VirtualAllocFlags -> ProtectFlags -> IO Addr
virtualAlloc addt size ty flags =
  failIfNull "VirtualAlloc" $ c_VirtualAlloc addt size ty flags
foreign import WINDOWS_CCONV unsafe "windows.h VirtualAlloc"
  c_VirtualAlloc :: Addr -> SIZE_T -> DWORD -> DWORD -> IO Addr

-- %fun VirtualAllocEx :: HANDLE -> Addr -> DWORD -> VirtualAllocFlags -> ProtectFlags ->IO Addr
-- %code extern LPVOID WINAPI VirtualAllocEx(HANDLE,LPVOID,DWORD,DWORD,DWORD);
-- %     LPVOID res1=VirtualAllocEx(arg1,arg2,arg3,arg4,arg5);
-- %fail {res1==NULL}{ErrorWin("VirtualAllocEx")}

virtualFree :: Addr -> SIZE_T -> FreeFlags -> IO ()
virtualFree addr size flags =
  failIfFalse_ "VirtualFree" $ c_VirtualFree addr size flags
foreign import WINDOWS_CCONV unsafe "windows.h VirtualFree"
  c_VirtualFree :: Addr -> SIZE_T -> FreeFlags -> IO BOOL

-- %fun VirtualFreeEx :: HANDLE -> Addr -> DWORD -> FreeFlags -> IO ()
-- %code extern BOOL WINAPI VirtualFreeEx(HANDLE,LPVOID,DWORD,DWORD);
-- %     BOOL res1=VirtualFreeEx(arg1,arg2,arg3,arg4);
-- %fail {res1=0}{ErrorWin("VirtualFreeEx")}

virtualLock :: Addr -> SIZE_T -> IO ()
virtualLock addr size =
  failIfFalse_ "VirtualLock" $ c_VirtualLock addr size
foreign import WINDOWS_CCONV unsafe "windows.h VirtualLock"
  c_VirtualLock :: Addr -> SIZE_T -> IO BOOL

virtualProtect :: Addr -> SIZE_T -> ProtectFlags -> IO ProtectFlags
virtualProtect addr size new_prot =
  alloca $ \ p_old -> do
  failIfFalse_ "VirtualProtect" $ c_VirtualProtect addr size new_prot p_old
  peek p_old
foreign import WINDOWS_CCONV unsafe "windows.h VirtualProtect"
  c_VirtualProtect :: Addr -> SIZE_T -> DWORD -> Ptr DWORD -> IO BOOL

virtualProtectEx :: HANDLE -> Addr -> SIZE_T -> ProtectFlags -> IO ProtectFlags
virtualProtectEx proc addr size new_prot =
  alloca $ \ p_old -> do
  failIfFalse_ "VirtualProtectEx" $
    c_VirtualProtectEx proc addr size new_prot p_old
  peek p_old
foreign import WINDOWS_CCONV unsafe "windows.h VirtualProtectEx"
  c_VirtualProtectEx :: HANDLE -> Addr -> SIZE_T -> DWORD -> Ptr DWORD -> IO BOOL

-- No VirtualQuery..()

virtualUnlock :: Addr -> SIZE_T -> IO ()
virtualUnlock addr size =
  failIfFalse_ "VirtualUnlock" $ c_VirtualUnlock addr size
foreign import WINDOWS_CCONV unsafe "windows.h VirtualUnlock"
  c_VirtualUnlock :: Addr -> SIZE_T -> IO BOOL
