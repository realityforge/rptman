#!/usr/bin/env ruby
# Copyright(c) 2005 URABE, Shyouhei.
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of  this code, to  deal in  the code  without restriction,  including without
# limitation  the rights  to  use, copy,  modify,  merge, publish,  distribute,
# sublicense, and/or sell copies of the code, and to permit persons to whom the
# code is furnished to do so, subject to the following conditions:
#
#        The above copyright notice and this permission notice shall be
#        included in all copies or substantial portions of the code.
#
# THE  CODE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND, EXPRESS  OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES  OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE  AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHOR  OR  COPYRIGHT  HOLDER BE  LIABLE  FOR  ANY  CLAIM, DAMAGES  OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF  OR IN CONNECTION WITH  THE CODE OR THE  USE OR OTHER  DEALINGS IN THE
# CODE.

%w[
	digest/md5
	digest/sha1
	socket
	tmpdir
].each do |f|
  require f
end

module SSRS
# Pure ruby UUID generator, which is compatible with RFC4122
  UUID = Struct.new "SSRS::UUID", :raw_bytes
  class UUID
    private_class_method :new

    class << self
      def mask str # :nodoc
        v = str[7]
        v = v & 0b00001111
        v = v | 0b01010000
        str[7] = v
        r = str[8]
        r = r & 0b00111111
        r = r | 0b10000000
        str[8] = r
        str
      end
      private :mask

      # UUID  generation  using  random-number  generator.   From  it's  random
      # nature, there's  no warranty that  the created ID is  really universaly
      # unique.
      def create
        rnd = [
          rand(0x100000000),
          rand(0x100000000),
          rand(0x100000000),
          rand(0x100000000),
        ].pack "N4"
        raw = mask rnd
        ret = new raw
        ret.raw_bytes.freeze
        ret.freeze
        ret
      end

      # A  simple GUID  parser:  just ignores  unknown  characters and  convert
      # hexadecimal dump into 16-octet object.
      def parse obj
        str = obj.to_s.sub %r/\Aurn:uuid:/, ''
        str.gsub! %r/[^0-9A-Fa-f]/, ''
        raw = str[0..31].to_a.pack 'H*'
        ret = new raw
        ret.raw_bytes.freeze
        ret.freeze
        ret
      end

      # The 'primitive constructor' of this class
      # Note UUID.pack(uuid.unpack) == uuid
      def pack tl, tm, th, ch, cl, n
        raw = [tl, tm, th, ch, cl, n].pack "NnnCCa6"
        ret = new raw
        ret.raw_bytes.freeze
        ret.freeze
        ret
      end
    end

    # The 'primitive deconstructor', or the dual to pack.
    # Note UUID.pack(uuid.unpack) == uuid
    def unpack
      raw_bytes.unpack "NnnCCa6"
    end

    # Generate the string representation (a.k.a GUID) of this UUID
    def to_s
      a = unpack
      tmp = a[-1].unpack 'C*'
      a[-1] = sprintf '%02x%02x%02x%02x%02x%02x', *tmp
      "%08x-%04x-%04x-%02x%02x-%s" % a
    end
    alias guid to_s

    # Convert into a RFC4122-comforming URN representation
    def to_uri
      "urn:uuid:" + self.to_s
    end
    alias urn to_uri

    # Convert into 128-bit unsigned integer
    # Typically a Bignum instance, but can be a Fixnum.
    def to_int
      tmp = self.raw_bytes.unpack "C*"
      tmp.inject do |r, i|
        r * 256 | i
      end
    end
    alias to_i to_int

    # Two  UUIDs  are  said  to  be  equal if  and  only  if  their  (byte-order
    # canonicalized) integer representations are equivallent.  Refer RFC4122 for
    # details.
    def == other
      to_i == other.to_i
    end

    include Comparable
    # UUIDs are comparable (don't know what benefits are there, though).
    def <=> other
      to_s <=> other.to_s
    end
  end
end
