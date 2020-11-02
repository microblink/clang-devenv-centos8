FROM microblinkdev/clang-devenv:10.0.0 AS original

FROM centos:8

COPY --from=original /usr/local /usr/local/
COPY --from=original /home /home/

# install LFS and setup global .gitignore for both
# root and every other user logged with -u user:group docker run parameter
RUN yum -y install openssh-clients glibc-devel java-devel zip bzip2 make perl-Digest-MD5 perl-JSON && \
    git lfs install && \
    echo "~*" >> /.gitignore_global && \
    echo ".DS_Store" >> /.gitignore_global && \
    echo "[core]" >> /root/.gitconfig && \
    echo "	excludesfile = /.gitignore_global" >> /root/.gitconfig && \
    cp /root/.gitconfig /.config && \
    git config --global user.email "developer@microblink.com" && \
    git config --global user.name "Developer" && \
    dbus-uuidgen > /etc/machine-id && \
    echo "bind '\"\\e[A\": history-search-backward'" >> ~/.bashrc && \
    echo "bind '\"\\e[B\": history-search-forward'" >> ~/.bashrc && \
    echo "bind \"set completion-ignore-case on\"" >> ~/.bashrc

COPY --from=original /lib64/libcrypto.so.10     /lib64/libcrypto.so.10
COPY --from=original /lib64/libssl.so.10        /lib64/libssl.so.10
COPY --from=original /lib64/libgssapi_krb5.so.2 /lib64/libgssapi_krb5.so.2
COPY --from=original /lib64/libkrb5.so.3        /lib64/libkrb5.so.3
COPY --from=original /lib64/libk5crypto.so.3    /lib64/libk5crypto.so.3
COPY --from=original /lib64/libkrb5support.so.0 /lib64/libkrb5support.so.0
COPY --from=original /lib64/libkeyutils.so.1    /lib64/libkeyutils.so.1
COPY --from=original /lib64/libkrb5support.so.0 /lib64/libkrb5support.so.0
COPY --from=original /lib64/libkeyutils.so.1    /lib64/libkeyutils.so.1
COPY --from=original /lib64/libkrb5support.so.0 /lib64/libkrb5support.so.0
COPY --from=original /lib64/libkeyutils.so.1    /lib64/libkeyutils.so.1
COPY --from=original /lib64/libtinfo.so.5       /lib64/libtinfo.so.5

COPY --from=original /usr/bin/jsawk /usr/bin/jsawk
COPY --from=original /usr/bin/pp    /usr/bin/pp
COPY --from=original /usr/bin/js    /usr/bin/js

# create gcc/g++ symlinks in /usr/bin (compatibility with legacy clang conan profile)
# and also replace binutils tools with LLVM version
RUN ln -s /usr/local/bin/clang   /usr/bin/clang   && \
    ln -s /usr/local/bin/clang++ /usr/bin/clang++ && \
    rm /usr/bin/nm /usr/bin/ranlib /usr/bin/ar    && \
    ln /usr/local/bin/llvm-ar     /usr/bin/ar     && \
    ln /usr/local/bin/llvm-nm     /usr/bin/nm     && \
    ln /usr/local/bin/llvm-ranlib /usr/bin/ranlib && \
    ln -s /usr/local/bin/ccache   /usr/bin/ccache

ENV CC="/usr/local/bin/clang"                           \
    CXX="/usr/local/bin/clang++"                        \
    AR="/usr/local/bin/llvm-ar"                         \
    NM="/usr/local/bin/llvm-nm"                         \
    RANLIB="/usr/local/bin/llvm-ranlib"                 \
    NINJA_STATUS="[%f/%t %c/sec] "                      \
    LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64"   \
    ANDROID_SDK_ROOT="/home/android-sdk"                \
    PATH="${PATH}:/home/android-sdk/platform-tools"

# download and install latest chrome
RUN cd /home && \
    curl -o chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
    yum -y install chrome.rpm && \
    rm chrome.rpm
