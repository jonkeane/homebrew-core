class Cgns < Formula
  desc "CFD General Notation System"
  homepage "http://cgns.org/"
  url "https://github.com/CGNS/CGNS/archive/v4.2.0.tar.gz"
  sha256 "090ec6cb0916d90c16790183fc7c2bd2bd7e9a5e3764b36c8196ba37bf1dc817"
  license "BSD-3-Clause"
  head "https://github.com/CGNS/CGNS.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "abc3326bddbf58509b5ffb3834d68836ad803abf83f9958ae6a012870e7e9f85"
    sha256 cellar: :any, big_sur:       "e2e5eb665f0f5c94c7782f0aed3708124705792ff5a7adf945a537369db6d724"
    sha256 cellar: :any, catalina:      "4371c695cad1aa0bccbaaf0deccb9a8f5ddf7271dcbbddf6307b8d0bc254cec5"
    sha256 cellar: :any, mojave:        "d9904ca7c839a5d0421b99ba784e98fec047971de47efa5d3cc00725cd892e26"
    sha256 cellar: :any, high_sierra:   "8bfeb33c22f79c998b31fea6aafc60aecf2edf18ea754799c67c012d90555ec9"
  end

  depends_on "cmake" => :build
  depends_on "gcc"
  depends_on "hdf5"
  depends_on "szip"

  uses_from_macos "zlib"

  def install
    args = std_cmake_args + %w[
      -DCGNS_ENABLE_64BIT=YES
      -DCGNS_ENABLE_FORTRAN=YES
      -DCGNS_ENABLE_HDF5=YES
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # Avoid references to Homebrew shims
    inreplace include/"cgnsBuild.defs", HOMEBREW_LIBRARY/"Homebrew/shims/mac/super/clang", "/usr/bin/clang"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include "cgnslib.h"
      int main(int argc, char *argv[])
      {
        int filetype = CG_FILE_NONE;
        if (cg_is_cgns(argv[0], &filetype) != CG_ERROR)
          return 1;
        return 0;
      }
    EOS
    system Formula["hdf5"].opt_prefix/"bin/h5cc", testpath/"test.c", "-L#{opt_lib}", "-lcgns"
    system "./a.out"
  end
end
