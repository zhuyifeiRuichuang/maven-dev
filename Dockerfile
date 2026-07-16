# 必须使用指定的基础镜像
FROM maven:3.8.7-openjdk-18

# 创建存放git 的目录
RUN mkdir -p /usr/local/git

# 在线下载 git 源码包（补充 diffutils 提供 cmp 命令）
RUN microdnf install -y wget gcc make openssl-devel zlib-devel libcurl-devel expat-devel gettext-devel perl-CPAN diffutils \
    && wget -O /tmp/git.tar.gz https://www.kernel.org/pub/software/scm/git/git-2.55.0.tar.gz

# 解压包到指定目录，编译安装，删除压缩包
RUN tar -zxf /tmp/git.tar.gz -C /usr/local/git --strip-components=1 \
    && cd /usr/local/git \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && rm -f /tmp/git.tar.gz \
    && microdnf clean all

# 将 git 可执行文件目录添加到系统 PATH，确保全局可调用
ENV PATH="/usr/local/git/bin:${PATH}"

# 验证 git 是否可用（构建时检查）
RUN git --version || { echo "git 安装失败"; exit 1; }
