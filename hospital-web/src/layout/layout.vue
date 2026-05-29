<template lang="html">
  <div class="layout-container">
    <!-- 顶部导航栏 -->
    <header class="layout-header">
      <div class="header-content">
        <div class="header-left">
          <div class="hospital-logo">
            <img src="../../商标.png" alt="云岚宗医院" class="logo-img">
          </div>
          <div class="hospital-info">
            <h1>云岚宗医院</h1>
            <p>智慧预约挂号管理系统</p>
          </div>
        </div>
        <div class="header-center">
          <el-breadcrumb separator="/" class="breadcrumb">
            <el-breadcrumb-item :to="{ path: '/home/dashboard' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-for="item in $route.matched" :key="item.path">
              {{ item.meta.title }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-button class="back-lobby-btn" @click="goToLobby">
            <i class="el-icon-s-home"></i> 返回大厅
          </el-button>
          <el-dropdown trigger="hover" @command="handleCommand">
            <span class="user-dropdown">
              <i class="el-icon-user"></i>
              <span class="username">{{ sysUserName }}</span>
              <i class="el-icon-arrow-down"></i>
            </span>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item command="home">
                <i class="el-icon-s-home"></i> 返回首页
              </el-dropdown-item>
              <el-dropdown-item command="public">
                <i class="el-icon-monitor"></i> 访问官网
              </el-dropdown-item>
              <el-dropdown-item divided command="logout">
                <i class="el-icon-switch-button"></i> 退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
      </div>
    </header>

    <!-- 主体内容 -->
    <div class="layout-main">
      <!-- 左侧导航栏 -->
      <aside class="layout-sidebar" :class="{ 'is-collapsed': isCollapsed }">
        <div class="sidebar-toggle" @click="toggleSidebar">
          <i :class="isCollapsed ? 'el-icon-s-unfold' : 'el-icon-s-fold'"></i>
        </div>
        <el-menu
          :default-active="$route.path"
          :collapse="isCollapsed"
          class="sidebar-menu"
          unique-opened
          background-color="#075f42"
          text-color="rgba(255,255,255,0.7)"
          active-text-color="#ffffff"
          router
        >
          <template v-for="(item, index) in menuRoutes">
            <el-submenu v-if="item.children && item.children.length > 1" :key="index" :index="item.path || String(index)">
              <template slot="title">
                <i :class="item.meta.icon"></i>
                <span>{{ item.meta.title }}</span>
              </template>
              <el-menu-item
                v-for="(child, childIndex) in item.children"
                :key="childIndex"
                :index="child.path"
              >
                <i :class="child.meta.icon"></i>
                <span>{{ child.meta.title }}</span>
              </el-menu-item>
            </el-submenu>
            <el-menu-item v-else-if="item.children && item.children.length === 1" :key="index" :index="item.children[0].path">
              <i :class="item.meta.icon"></i>
              <span>{{ item.meta.title }}</span>
            </el-menu-item>
          </template>
        </el-menu>
      </aside>

      <!-- 内容区域 -->
      <section class="layout-content">
        <transition name="fade" mode="out-in">
          <router-view></router-view>
        </transition>
      </section>
    </div>
  </div>
</template>

<script>
  import Cookie from 'js-cookie';
  import {getCookie} from "@/utils/cookies";

  export default {
    name: "layout",
    data() {
      return {
        sysUserName: '',
        isCollapsed: false,
        menuRoutes: []
      }
    },
    methods: {
      toggleSidebar() {
        this.isCollapsed = !this.isCollapsed;
      },
      handleCommand(command) {
        switch (command) {
          case 'home':
            this.$router.push('/home/dashboard');
            break;
          case 'public':
            this.$router.push('/');
            break;
          case 'logout':
            this.logoutFun();
            break;
        }
      },
      goToLobby() {
        this.$router.push('/');
      },
      logoutFun() {
        this.$confirm('确认退出吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          sessionStorage.removeItem('accountID');
          sessionStorage.removeItem('user');
          Cookie.remove('username');
          Cookie.remove('token');
          Cookie.remove('appoint_admin');
          const {resetPermission} = require('@/permission');
          resetPermission();
          this.$router.push('/');
        }).catch(() => {});
      },
      loadMenuRoutes() {
        const routes = this.$router.options.routes || [];
        this.menuRoutes = routes
          .filter(item => {
            return !item.hidden && item.path !== '/login' && item.path !== '/404' && item.name !== 'publicIndex';
          })
          .map(item => {
            return {
              ...item,
              children: (item.children || []).filter(child => !child.hidden)
            };
          })
          .filter(item => item.children && item.children.length);
      }
    },
    created() {
      this.sysUserName = getCookie('username') || '用户';
      this.$nextTick(() => {
        this.loadMenuRoutes();
      });
      // 延迟重新加载，确保权限路由已注入
      setTimeout(() => {
        this.loadMenuRoutes();
      }, 500);
    },
    watch: {
      '$route'() {
        this.loadMenuRoutes();
      }
    }
  }
</script>

<style lang="scss">
  $primary-color: #075f42;
  $primary-light: #20a978;
  $sidebar-width: 220px;
  $sidebar-collapsed-width: 64px;
  $header-height: 60px;

  .layout-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    background: #f0f2f5;
  }

  .layout-header {
    height: $header-height;
    background: linear-gradient(135deg, $primary-color, $primary-light);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
  }

  .header-content {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;
  }

  .header-left {
    display: flex;
    align-items: center;

    .hospital-logo {
      width: 40px;
      height: 40px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 12px;
      overflow: hidden;

      .logo-img {
        width: 100%;
        height: 100%;
        object-fit: contain;
      }

      i {
        color: white;
        font-size: 22px;
      }
    }

    .hospital-info {
      h1 {
        font-size: 18px;
        color: white;
        margin: 0;
        font-weight: 600;
        letter-spacing: 1px;
      }

      p {
        font-size: 11px;
        color: rgba(255, 255, 255, 0.8);
        margin: 2px 0 0;
      }
    }
  }

  .header-center {
    flex: 1;
    margin-left: 40px;
  }

  .breadcrumb {
    background: transparent !important;
  }

  .breadcrumb .el-breadcrumb__inner {
    color: rgba(255, 255, 255, 0.8) !important;
  }

  .breadcrumb .el-breadcrumb__item:last-child .el-breadcrumb__inner {
    color: white !important;
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 12px;

    .back-lobby-btn {
      background: rgba(255, 255, 255, 0.15);
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: white;
      padding: 8px 16px;
      font-size: 13px;
      border-radius: 6px;
      transition: all 0.3s;

      &:hover {
        background: rgba(255, 255, 255, 0.25);
        border-color: rgba(255, 255, 255, 0.5);
      }

      i {
        margin-right: 4px;
      }
    }

    .user-dropdown {
      display: flex;
      align-items: center;
      color: white;
      cursor: pointer;
      padding: 6px 12px;
      border-radius: 6px;
      transition: background 0.3s;

      &:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      .username {
        margin: 0 8px;
        font-size: 14px;
      }

      i {
        font-size: 16px;
      }
    }
  }

  .layout-main {
    display: flex;
    margin-top: $header-height;
    min-height: calc(100vh - #{$header-height});
  }

  .layout-sidebar {
    width: $sidebar-width;
    background: $primary-color;
    transition: width 0.3s;
    overflow: hidden;
    position: fixed;
    top: $header-height;
    bottom: 0;
    left: 0;
    z-index: 999;

    &.is-collapsed {
      width: $sidebar-collapsed-width;
    }
  }

  .sidebar-toggle {
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0, 0, 0, 0.1);
    cursor: pointer;
    color: white;
    transition: background 0.3s;

    &:hover {
      background: rgba(0, 0, 0, 0.2);
    }

    i {
      font-size: 20px;
    }
  }

  .sidebar-menu {
    border-right: none !important;
    height: calc(100% - 40px);
    overflow-y: auto;

    &::-webkit-scrollbar {
      width: 4px;
    }

    &::-webkit-scrollbar-thumb {
      background: rgba(255, 255, 255, 0.2);
      border-radius: 2px;
    }

    .el-submenu__title,
    .el-menu-item {
      height: 48px;
      line-height: 48px;

      &:hover {
        background: rgba(255, 255, 255, 0.1) !important;
      }
    }

    .el-menu-item.is-active {
      background: $primary-light !important;
    }

    .el-submenu .el-menu {
      background: rgba(0, 0, 0, 0.1) !important;
    }

    .el-menu-item i,
    .el-submenu__title i {
      color: rgba(255, 255, 255, 0.7);
      margin-right: 10px;
    }

    .el-menu-item.is-active i {
      color: white;
    }
  }

  .layout-content {
    flex: 1;
    margin-left: $sidebar-width;
    padding: 20px;
    transition: margin-left 0.3s;
    overflow-y: auto;

    .is-collapsed ~ & {
      margin-left: $sidebar-collapsed-width;
    }
  }

  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.2s;
  }

  .fade-enter,
  .fade-leave-to {
    opacity: 0;
  }
</style>
