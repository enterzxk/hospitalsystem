<template>
  <div class="login-page">
    <!-- 顶部导航栏 -->
    <div class="header-bar">
      <div class="header-content">
        <div class="logo-section">
          <div class="hospital-logo">
            <i class="el-icon-first-aid-kit"></i>
          </div>
          <div class="hospital-name">
            <h1>云岚宗医院</h1>
            <p>YUNLANZONG MEDICAL CENTER</p>
          </div>
        </div>
        <div class="nav-links">
          <a href="#" @click.prevent="goToPublic('top')">首页</a>
          <a href="#" @click.prevent="goToPublic('about')">医院概况</a>
          <a href="#" @click.prevent="goToPublic('departments')">科室导航</a>
          <a href="#" @click.prevent="goToPublic('guide')">就医指南</a>
          <a href="#" @click.prevent="goToPublic('news')">科研教学</a>
        </div>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="main-content">
      <div class="login-left">
        <div class="brand-area">
          <div class="brand-icon">
            <i class="el-icon-first-aid-kit"></i>
          </div>
          <h1>智慧预约挂号系统</h1>
          <p>让就医更简单，让健康更可及</p>
          <div class="feature-list">
            <div class="feature-item">
              <i class="el-icon-check"></i>
              <span>在线预约挂号</span>
            </div>
            <div class="feature-item">
              <i class="el-icon-check"></i>
              <span>就诊记录查询</span>
            </div>
            <div class="feature-item">
              <i class="el-icon-check"></i>
              <span>影像报告查看</span>
            </div>
          </div>
        </div>
      </div>
      <div class="login-right">
        <div class="login-container">
          <div class="login-header">
            <h2>欢迎回来</h2>
            <p>登录您的账号以继续</p>
          </div>
          <el-form :model="ruleForm2" :rules="rules2" ref="ruleForm2" label-position="left"
                   label-width="0px" class="login-form">
            <el-form-item prop="username">
              <el-input type="text" v-model="ruleForm2.username" auto-complete="off"
                        placeholder="请输入账号" prefix-icon="el-icon-user"></el-input>
            </el-form-item>
            <el-form-item prop="password">
              <el-input type="password" v-model="ruleForm2.password" auto-complete="off"
                        placeholder="请输入密码" prefix-icon="el-icon-lock"
                        @keyup.enter.native="handleSubmit2"></el-input>
            </el-form-item>
            <el-form-item class="form-options">
              <el-checkbox v-model="checked" class="remember">记住密码</el-checkbox>
              <a href="#" class="forgot-password">忘记密码？</a>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" class="login-btn" @click="handleSubmit2" :loading="loading">
                登 录
              </el-button>
            </el-form-item>
          </el-form>
          <div class="login-footer">
            <div class="demo-title">演示账号</div>
            <div class="demo-grid">
              <div class="demo-group">
                <span class="demo-label">管理员</span>
                <span class="demo-value">admin / admin</span>
              </div>
              <div class="demo-group">
                <span class="demo-label">医生</span>
                <span class="demo-value">doctor1 / 123456</span>
              </div>
              <div class="demo-group">
                <span class="demo-label">影像</span>
                <span class="demo-value">radiologist1 / 123456</span>
              </div>
              <div class="demo-group">
                <span class="demo-label">患者</span>
                <span class="demo-value">patient1 / 123456</span>
              </div>
              <div class="demo-group">
                <span class="demo-label">更多</span>
                <span class="demo-value">doctor2 / doctor123，patient2 / patient123</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部信息 -->
    <div class="footer-bar">
      <div class="footer-content">
        <div class="footer-info">
          <p>© 2024 云岚宗医院 版权所有</p>
          <p>地址：云岚市青澜区云岚宗大道88号 | 邮编：310188 | 电话：0571-8808-6677</p>
        </div>
        <div class="footer-links">
          <a href="#">法律声明</a>
          <a href="#">隐私政策</a>
          <a href="#">联系我们</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import Cookie from "js-cookie";
  import {getCookie, setCookie} from "@/utils/cookies";
  import {setToken} from "@/utils/auth";
  import {resetPermission} from "@/permission";

  export default {
    name: "login",
    data(){
      return{
        loading: false,
        ruleForm2: {
          username: '',
          password: ''
        },
        rules2: {
          username: [{ required: true, message: '请输入账号',trigger: 'blur'}],
          password: [{required: true,message: '请输入密码',trigger: 'blur'}]
        },
        checked: false,
        redirect: undefined
      }
    },
    watch: {
      $route: {
        handler: function(route) {
          this.redirect = route.query && route.query.redirect
        },
        immediate: true
      }
    },
    methods: {
      goToPublic(section) {
        this.$router.push({ path: '/', query: { section: section || 'top' } });
      },
      handleSubmit2(ev) {
        var _this = this;
        _this.$refs.ruleForm2.validate((valid) => {
          if (valid) {
            _this.loading = true;

            // 实现登录
              this.$store.dispatch('Login', this.ruleForm2).then(() => {
              this.persistLoginState();

              _this.$router.push({path: this.redirect || '/home/dashboard'});
              _this.loading = false

            }).catch(() => {
              _this.loading = false;
              if (this.tryDemoLogin()) {
                return;
              }
              _this.$alert('用户名或密码错误！', '提示信息', {
                confirmButtonText: '确定'
              });
            })
          } else {
            console.log('error submit!!');
            return false;
          }
        });

      },
      persistLoginState() {
        const expires = this.checked ? 15 : 1;
        setCookie("username", this.ruleForm2.username, expires);
        sessionStorage.setItem('username', this.ruleForm2.username);
        sessionStorage.setItem('accountID', this.ruleForm2.username);
        resetPermission();
        if (this.checked) {
          setCookie("password", this.ruleForm2.password, 15);
        } else {
          Cookie.remove("password");
        }
      },
      tryDemoLogin() {
        const demoAccounts = {
          admin: 'admin',
          doctor1: '123456',
          doctor2: 'doctor123',
          doctor3: '123456',
          radiologist1: '123456',
          patient1: '123456',
          patient2: 'patient123',
          patient3: '123456',
          patient4: '123456'
        };
        const username = (this.ruleForm2.username || '').trim();
        if (demoAccounts[username] !== this.ruleForm2.password) {
          return false;
        }
        setToken('Bearer demo-token-' + username);
        this.persistLoginState();
        this.$message.success('已使用演示账号登录');
        this.$router.push({path: this.redirect || '/home/dashboard'});
        return true;
      }
    },
    created() {
      this.ruleForm2.username = getCookie('username');
      this.ruleForm2.password = getCookie('password');
      if(this.ruleForm2.username === undefined||this.ruleForm2.username==null||this.ruleForm2.username===''){
        this.ruleForm2.username = 'admin';
      }
      if(this.ruleForm2.password === undefined||this.ruleForm2.password==null){
        this.ruleForm2.password = '';
      }
    }
  }
</script>

<style lang="scss">
  .login-page {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    background:
      linear-gradient(135deg, rgba(0, 68, 50, 0.72), rgba(9, 129, 91, 0.36)),
      url('../../../../医院背景图.png') center/cover fixed no-repeat;
  }

  .header-bar {
    background: rgba(255, 255, 255, 0.98);
    box-shadow: 0 1px 8px rgba(0, 0, 0, 0.06);
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
  }

  .header-content {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 30px;
    height: 70px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .logo-section {
    display: flex;
    align-items: center;
  }

  .hospital-logo {
    width: 44px;
    height: 44px;
    background: linear-gradient(135deg, #007a4d, #20a978);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 14px;

    i {
      color: white;
      font-size: 22px;
    }
  }

  .hospital-name {
    h1 {
      font-size: 20px;
      color: #075f42;
      margin: 0;
      font-weight: 700;
      letter-spacing: 1px;
    }

    p {
      font-size: 10px;
      color: #999;
      margin: 0;
      letter-spacing: 1px;
    }
  }

  .nav-links {
    display: flex;
    gap: 28px;

    a {
      color: #555;
      text-decoration: none;
      font-size: 14px;
      transition: color 0.3s;
      position: relative;

      &:hover {
        color: #007a4d;
      }

      &::after {
        content: '';
        position: absolute;
        bottom: -4px;
        left: 0;
        width: 0;
        height: 2px;
        background: #007a4d;
        transition: width 0.3s;
      }

      &:hover::after {
        width: 100%;
      }
    }
  }

  .main-content {
    flex: 1;
    display: flex;
    padding-top: 70px;
    min-height: 100vh;
  }

  .login-left {
    flex: 1;
    background:
      linear-gradient(135deg, rgba(7, 95, 66, 0.92) 0%, rgba(13, 138, 94, 0.76) 52%, rgba(32, 169, 120, 0.44) 100%),
      url('../../../../医院背景图.png') center/cover no-repeat;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 60px;
    position: relative;
    overflow: hidden;

    &::before {
      content: '';
      position: absolute;
      top: -50%;
      right: -20%;
      width: 500px;
      height: 500px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.05);
    }

    &::after {
      content: '';
      position: absolute;
      bottom: -30%;
      left: -10%;
      width: 400px;
      height: 400px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.03);
    }
  }

  .brand-area {
    position: relative;
    z-index: 1;
    color: white;
    max-width: 420px;

    .brand-icon {
      width: 72px;
      height: 72px;
      background: rgba(255, 255, 255, 0.15);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 28px;
      backdrop-filter: blur(10px);

      i {
        font-size: 36px;
        color: white;
      }
    }

    h1 {
      font-size: 36px;
      font-weight: 700;
      margin: 0 0 12px;
      letter-spacing: 2px;
    }

    p {
      font-size: 16px;
      opacity: 0.85;
      margin: 0 0 36px;
      line-height: 1.6;
    }
  }

  .feature-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .feature-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    backdrop-filter: blur(5px);

    i {
      font-size: 16px;
      color: #7ee8bd;
    }

    span {
      font-size: 15px;
      opacity: 0.95;
    }
  }

  .login-right {
    width: 520px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 60px 40px;
    background: rgba(255, 255, 255, 0.94);
    backdrop-filter: blur(10px);
  }

  .login-container {
    width: 100%;
    max-width: 400px;
  }

  .login-header {
    margin-bottom: 36px;

    h2 {
      font-size: 28px;
      color: #075f42;
      margin: 0 0 8px;
      font-weight: 700;
    }

    p {
      color: #999;
      font-size: 14px;
      margin: 0;
    }
  }

  .login-form {
    .el-form-item {
      margin-bottom: 22px;
    }

    .el-input {
      height: 46px;
    }

    .el-input__inner {
      border-radius: 10px;
      border: 1.5px solid #e0e6e3;
      padding-left: 42px;
      font-size: 14px;
      transition: all 0.3s;
      background: #f8faf9;

      &:focus {
        border-color: #20a978;
        box-shadow: 0 0 0 3px rgba(32, 169, 120, 0.12);
        background: white;
      }
    }

    .el-input__prefix {
      left: 14px;
      color: #aab5ae;
    }

    .form-options {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 22px;

      .el-form-item__content {
        display: flex;
        justify-content: space-between;
        width: 100%;
      }
    }

    .remember {
      color: #666;
      font-size: 13px;
    }

    .forgot-password {
      color: #007a4d;
      font-size: 13px;
      text-decoration: none;
      font-weight: 500;

      &:hover {
        text-decoration: underline;
      }
    }
  }

  .login-btn {
    width: 100%;
    height: 48px;
    font-size: 16px;
    border-radius: 10px;
    background: linear-gradient(135deg, #075f42, #20a978);
    border: none;
    letter-spacing: 6px;
    font-weight: 600;
    transition: all 0.3s;

    &:hover {
      background: linear-gradient(135deg, #065538, #1a9468);
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(7, 95, 66, 0.35);
    }

    &:active {
      transform: translateY(0);
    }
  }

  .login-footer {
    margin-top: 28px;
    padding-top: 20px;
    border-top: 1px solid #eef2f0;

    .demo-title {
      font-size: 12px;
      color: #999;
      margin-bottom: 12px;
      text-align: center;
      text-transform: uppercase;
      letter-spacing: 2px;
    }

    .demo-grid {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .demo-group {
      display: flex;
      align-items: center;
      padding: 8px 12px;
      background: #f8faf9;
      border-radius: 8px;

      .demo-label {
        font-size: 12px;
        color: #075f42;
        font-weight: 600;
        width: 48px;
        flex-shrink: 0;
      }

      .demo-value {
        font-size: 12px;
        color: #666;
        font-family: 'Courier New', monospace;
      }
    }
  }

  .footer-bar {
    background: #075f42;
    padding: 18px 0;
  }

  .footer-content {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .footer-info {
    p {
      color: rgba(255, 255, 255, 0.7);
      font-size: 12px;
      margin: 4px 0;
    }
  }

  .footer-links {
    display: flex;
    gap: 20px;

    a {
      color: rgba(255, 255, 255, 0.7);
      text-decoration: none;
      font-size: 12px;
      transition: color 0.3s;

      &:hover {
        color: white;
      }
    }
  }
</style>
