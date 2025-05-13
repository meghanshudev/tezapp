import 'dart:convert';
import 'dart:typed_data';
import 'dart:convert' show utf8;

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'package:pointycastle/pointycastle.dart';


String encrypt(String text , String key , String iv) 
{
  return base64Encode(encryptList(utf8.encode(text) as Uint8List, utf8.encode(key)  as Uint8List, utf8.encode(iv)  as Uint8List ));
}

Uint8List encryptList(Uint8List data, Uint8List key , Uint8List iv) 
{
  final CBCBlockCipher cbcCipher = new CBCBlockCipher(new AESFastEngine());
  final ParametersWithIV<KeyParameter> ivParams =
      new ParametersWithIV<KeyParameter>(new KeyParameter(key), iv);
  final PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>
      paddingParams =
      new PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
          ivParams, null);

  final PaddedBlockCipherImpl paddedCipher =
      new PaddedBlockCipherImpl(new PKCS7Padding(), cbcCipher);
  paddedCipher.init(true, paddingParams);

  //try {
    return paddedCipher.process(data);
  // } catch (e) {
  //   print(e);
  //   return null;
  // }
}



